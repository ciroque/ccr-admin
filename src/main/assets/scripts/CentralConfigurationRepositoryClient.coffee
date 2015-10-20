"use strict"

window.CentralConfigurationRepositoryClient = class CentralConfigurationRepositoryClient
  constructor: (@logger, @eventManager, opts = {}) ->
    @opts = AppTools.merge({ lib: $, ccrService: { protocol: 'http', host: 'localhost', port: 80 }}, opts)
    @cache = new ExpiringCache()

  buildWebQuery: (url, successEvent, failureEvent, success = null, failure = null) ->
    {
    lib: @opts.lib,
    url: "#{@opts.ccrService.protocol}://#{@opts.ccrService.host}:#{@opts.ccrService.port}/#{Strings.ServicePaths.RootPath}/#{Strings.ServicePaths.SettingSegment}/#{url}",
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
      '',
      Strings.Events.ServiceQueries.EnvironmentQuerySuccess,
      Strings.Events.ServiceQueries.EnvironmentQueryFailure
    ).execute()

  retrieveApplications: (environment) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveApplications')
    @buildWebQuery(
      "#{environment}",
      Strings.Events.ServiceQueries.ApplicationQuerySuccess,
      Strings.Events.ServiceQueries.ApplicationQueryFailure
    ).execute()

  retrieveScopes: (environment, application) ->
    @logger.debug("CentralConfigurationRepositoryClient::retrieveScopes('#{environment}', '#{application}')")
    @buildWebQuery(
      "#{environment}/#{application}",
      Strings.Events.ServiceQueries.ScopeQuerySuccess,
      Strings.Events.ServiceQueries.ScopeQueryFailure
    ).execute()

  retrieveSettings: (environment, application, scope) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveSettings')
    @buildWebQuery(
      "#{environment}/#{application}/#{scope}",
      Strings.Events.ServiceQueries.SettingQuerySuccess,
      Strings.Events.ServiceQueries.SettingQueryFailure
    ).execute()

  retrieveConfigurations: (environment, application, scope, setting, sourceId = null) ->
    @logger.debug('CentralConfigurationRepositoryClient::retrieveConfigurations')

    buildQueryPath = (includeSourceId = false) ->
      base = "#{environment}/#{application}/#{scope}/#{setting}"
      if sourceId && includeSourceId
        base + "?sourceId=#{sourceId}"
      else
        base

    cache = @cache
    successHandler = (result) ->
      cfg = result.configuration[0]
      cache.put(buildQueryPath(), cfg, cfg.temporality.ttl)

    webQuery = @buildWebQuery(
      "#{buildQueryPath(true)}",
      Strings.Events.ServiceQueries.ConfigurationQuerySuccess,
      Strings.Events.ServiceQueries.ConfigurationQueryFailure,
      successHandler
    )

    path = buildQueryPath()
    cfg = @cache.get(path)

    if cfg
      @logger.debug("CentralConfigurationRepositoryClient::retrieveConfigurations #{path} found in cache")
      webQuery.success({ configuration: [ cfg ] })

    else
      webQuery.execute()
