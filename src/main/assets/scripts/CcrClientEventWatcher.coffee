"use strict"

window.CcrClientEventWatcher = class CcrClientEventWatcher
  constructor: (@logger, @eventManager, @ccrClient) ->

  init: () ->
    @registerEventHandlers()

  registerEventHandlers: () ->
    ccrClient = @ccrClient
    eventManager = @eventManager
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateEnvironmentQuery, () ->
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearEnvironments, {})
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearApplications, {})
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearScopes, {})
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearSettings, {})
      ccrClient.retrieveEnvironments()
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateApplicationQuery, (args) ->
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearApplications, {})
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearScopes, {})
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearSettings, {})
      ccrClient.retrieveApplications(args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateScopeQuery, (args) ->
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearScopes, {})
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearSettings, {})
      ccrClient.retrieveScopes(args.env, args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateSettingQuery, (args) ->
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearSettings, {})
      ccrClient.retrieveSettings(args.env, args.app, args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateConfigurationQuery, (args) ->
      ccrClient.retrieveConfigurations(args.env, args.app, args.scp, args.value)
    )
