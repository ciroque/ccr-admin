"use strict"

window.CcrClientEventWatcher = class CcrClientEventWatcher
  constructor: (@logger, @eventManager, @ccrClient) ->

  init: () ->
    @registerEventHandlers()

  registerEventHandlers: () ->
    ccrClient = @ccrClient
    eventManager = @eventManager
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateEnvironmentQuery, () ->
      eventManager.dispatchEvents(
        Strings.Events.UiEvents.ClearEnvironments,
        Strings.Events.UiEvents.ClearApplications,
        Strings.Events.UiEvents.ClearScopes,
        Strings.Events.UiEvents.ClearSettings,
        Strings.Events.UiEvents.ClearConfiguration)
      ccrClient.retrieveEnvironments()
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateApplicationQuery, (args) ->
      eventManager.dispatchEvents(
        Strings.Events.UiEvents.ClearApplications,
        Strings.Events.UiEvents.ClearScopes,
        Strings.Events.UiEvents.ClearSettings,
        Strings.Events.UiEvents.ClearConfiguration)
      ccrClient.retrieveApplications(args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateScopeQuery, (args) ->
      eventManager.dispatchEvents(
        Strings.Events.UiEvents.ClearScopes,
        Strings.Events.UiEvents.ClearSettings,
        Strings.Events.UiEvents.ClearConfiguration)
      ccrClient.retrieveScopes(args.env, args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateSettingQuery, (args) ->
      eventManager.dispatchEvents(
        Strings.Events.UiEvents.ClearSettings,
        Strings.Events.UiEvents.ClearConfiguration
      )
      ccrClient.retrieveSettings(args.env, args.app, args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateConfigurationQuery, (args) ->
      ccrClient.retrieveConfigurations(args.env, args.app, args.scp, args.value)
    )
