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
    @logger.debug('CentralConfigurationRepositoryClient::retrieveEnvironments')
    @buildWebQuery(
      "#{Strings.ServiceLocation.CcrProtocol}//#{Strings.ServiceLocation.CcrHost}:#{Strings.ServiceLocation.CcrPort}/#{Strings.ServicePaths.RootPath}/#{Strings.ServicePaths.SettingSegment}/#{environment}",
      Strings.Events.ServiceQueries.ApplicationQuerySuccess,
      Strings.Events.ServiceQueries.ApplicationQueryFailure
    ).execute()

  retrieveScopes: (environment, application) -> []

  retrieveSettings: (environment, application, scope) -> []

  retrieveConfiguration: (environment, application, scope, setting, sourceId = null) ->
    # check cache
    []
