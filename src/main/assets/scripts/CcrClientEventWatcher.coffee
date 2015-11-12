"use strict"

window.CcrClientEventWatcher = class CcrClientEventWatcher
  constructor: (@logger, @eventManager, @ccrClient) ->

  init: () ->
    @registerEventHandlers()

  registerEventHandlers: () ->
    ccrClient = @ccrClient
    eventManager = @eventManager
    logger = @logger
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateEnvironmentQuery, () ->
      eventManager.dispatchEvents(
        { name: Strings.Events.UiEvents.ClearEnvironments, args: {}},
        { name: Strings.Events.UiEvents.ClearApplications, args: {}},
        { name: Strings.Events.UiEvents.ClearScopes, args: {}},
        { name: Strings.Events.UiEvents.ClearSettings, args: {}},
        { name: Strings.Events.UiEvents.ClearConfiguration, args: {}})
      ccrClient.retrieveEnvironments()
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateApplicationQuery, (args) ->
      eventManager.dispatchEvents(
        { name: Strings.Events.UiEvents.ClearApplications, args: {}},
        { name: Strings.Events.UiEvents.ClearScopes, args: {}},
        { name: Strings.Events.UiEvents.ClearSettings, args: {}},
        { name: Strings.Events.UiEvents.ClearConfiguration, args: {}})
      ccrClient.retrieveApplications(args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateScopeQuery, (args) ->
      eventManager.dispatchEvents(
        { name: Strings.Events.UiEvents.ClearScopes, args: {}},
        { name: Strings.Events.UiEvents.ClearSettings, args: {}},
        { name: Strings.Events.UiEvents.ClearConfiguration, args: {}})
      ccrClient.retrieveScopes(args.env, args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateSettingQuery, (args) ->
      eventManager.dispatchEvents(
        { name: Strings.Events.UiEvents.ClearSettings, args: {}},
        { name: Strings.Events.UiEvents.ClearConfiguration, args: {}}
      )
      ccrClient.retrieveSettings(args.env, args.app, args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateConfigurationQuery, (args) ->
      eventManager.dispatchEvent(Strings.Events.UiEvents.ClearConfiguration)
      ccrClient.retrieveConfigurations(args.env, args.app, args.scp, args.value)
    )
    @eventManager.registerHandler(Strings.Events.ServiceCallTriggers.InitiateAuditingQuery, (args) ->
      ccrClient.retrieveAuditHistory(cfg._id) for cfg in args.configuration
    )
