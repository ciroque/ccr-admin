"use strict"

window.CentralConfigurationRepositoryClient = class CentralConfigurationRepositoryClient
  constructor: (@logger, @eventManager, @opts = { lib: $ }) ->
    @cache = new ExpiringCache()

  buildWebQuery: (url, successEvent, failureEvent, success = null, failure = null) ->
    {
    lib: @opts.lib,
    url: url,
    logger: @logger,
    eventManager: @eventManager,
    success: (result) ->
      success(result) if success?
      @eventManager.dispatchEvent(successEvent, result)
      @logger.debug("ServiceClient::AjaxCall to #{url} succeeded")
    fail: (error) ->
      failure(error) if failure?
      @eventManager.dispatchEvent(failureEvent, error)
      @logger.error("ServiceClient::AjaxCall to #{url} failed: #{error}")
    execute: (data = null, crossDomain = false, contentType = null) ->
      @contentType = contentType if contentType
      @data = data if data
      @lib.ajax(@)
    }

  retrieveEnvironments: ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveEnvironments')
    @buildWebQuery(
      "#{Strings.ServiceLocation.CcrProtocol}//#{Strings.ServiceLocation.CcrHost}:#{Strings.ServiceLocation.CcrPort}/#{Strings.ServicePaths.RootPath}/#{Strings.ServicePaths.SettingSegment}",
      Strings.Events.ServiceQueries.EnvironmentQuerySuccess,
      Strings.Events.ServiceQueries.EnvironmentQueryFailure
    ).execute()

  retrieveApplications: (environment) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveApplications')
    @buildWebQuery(
      "#{Strings.ServiceLocation.CcrProtocol}//#{Strings.ServiceLocation.CcrHost}:#{Strings.ServiceLocation.CcrPort}/#{Strings.ServicePaths.RootPath}/#{Strings.ServicePaths.SettingSegment}/#{environment}",
      Strings.Events.ServiceQueries.ApplicationQuerySuccess,
      Strings.Events.ServiceQueries.ApplicationQueryFailure
    ).execute()

  retrieveScopes: (environment, application) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveScopes')
    @buildWebQuery(
      "#{Strings.ServiceLocation.CcrProtocol}//#{Strings.ServiceLocation.CcrHost}:#{Strings.ServiceLocation.CcrPort}/#{Strings.ServicePaths.RootPath}/#{Strings.ServicePaths.SettingSegment}/#{environment}/#{application}",
      Strings.Events.ServiceQueries.ScopeQuerySuccess,
      Strings.Events.ServiceQueries.ScopeQueryFailure
    ).execute()

  retrieveSettings: (environment, application, scope) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveSettings')
    @buildWebQuery(
      "#{Strings.ServiceLocation.CcrProtocol}//#{Strings.ServiceLocation.CcrHost}:#{Strings.ServiceLocation.CcrPort}/#{Strings.ServicePaths.RootPath}/#{Strings.ServicePaths.SettingSegment}/#{environment}/#{application}/#{scope}",
      Strings.Events.ServiceQueries.SettingQuerySuccess,
      Strings.Events.ServiceQueries.SettingQueryFailure
    ).execute()

  retrieveConfigurations: (environment, application, scope, setting, sourceId = null) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveConfigurations')

    buildQueryPath = () ->
      base = "#{environment}/#{application}/#{scope}/#{setting}"
      if sourceId
        base + "?sourceId=#{sourceId}"
      else
        base

    cache = @cache
    successHandler = (result) ->
      cfg = result[0]
      cache.put(buildQueryPath(), cfg, cfg.temporality.ttl)

    webQuery = @buildWebQuery(
      "#{Strings.ServiceLocation.CcrProtocol}//#{Strings.ServiceLocation.CcrHost}:#{Strings.ServiceLocation.CcrPort}/#{Strings.ServicePaths.RootPath}/#{Strings.ServicePaths.SettingSegment}/#{buildQueryPath()}",
      Strings.Events.ServiceQueries.ConfigurationQuerySuccess,
      Strings.Events.ServiceQueries.ConfigurationQueryFailure,
      successHandler
    )

    path = buildQueryPath()
    cfg = @cache.get(path)

    if cfg
      @logger.debug("CentralConfigurationRepositoryClient::retrieveConfigurations #{path} found in cache")
      webQuery.success([cfg])

    else
      webQuery.execute()
