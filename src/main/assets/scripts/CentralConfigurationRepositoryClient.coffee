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
      @logger.debug("ServiceClient::AjaxCall to #{url} succeeded")
      success(result) if success?
      @eventManager.dispatchEvent(successEvent, result)
    fail: (error) ->
      @logger.error("ServiceClient::AjaxCall to #{url} failed: #{error}")
      failure(error) if failure?
      @eventManager.dispatchEvent(failureEvent, error)
    execute: (data = null, crossDomain = false, contentType = null) ->
      @contentType = contentType if contentType
      @data = data if data
      @lib.ajax(@)
    }

  retrieveEnvironments: -> []

  retrieveApplications: (environment) -> []

  retrieveScopes: (environment, application) -> []

  retrieveSettings: (environment, application, scope) -> []

  retrieveConfiguration: (environment, application, scope, setting, sourceId = null) ->
    # check cache
    []
