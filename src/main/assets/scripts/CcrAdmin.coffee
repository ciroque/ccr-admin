"use strict"

window.CcrAdmin = class CcrAdmin
  constructor: () ->
    @logger = new Logger({level: LogLevel.ALL})
    @eventManager = new EventManager(@logger)
    @eventMapper = new EventMapper(@logger, @eventManager)
    @ccrClient = new CentralConfigurationRepositoryClient(@logger, @eventManager, { ccrService: { protocol: 'http', host: 'localhost', port: 8378 } })
    @ccrClientEventWatcher = new CcrClientEventWatcher(@logger, @eventManager, @ccrClient)
    uiTemplates = new UiTemplates()
    uiTemplates.init()
    @environmentsList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.EnvironmentQuerySuccess,
        clearEvent: Strings.Events.UiEvents.ClearEnvironments,
        ele: $('#environmentsList'),
        template: uiTemplates.listItemTemplate
      })
    @applicationsList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.ApplicationQuerySuccess,
        clearEvent: Strings.Events.UiEvents.ClearApplications,
        ele: $('#applicationsList'),
        template: uiTemplates.listItemTemplate
      })
    @scopesList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.ScopeQuerySuccess,
        clearEvent: Strings.Events.UiEvents.ClearScopes,
        ele: $('#scopesList'),
        template: uiTemplates.listItemTemplate
      })
    @settingsList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.SettingQuerySuccess,
        clearEvent: Strings.Events.UiEvents.ClearSettings,
        ele: $('#settingsList'),
        template: uiTemplates.listItemTemplate
      })
    @configurationsPanel = new ValuesPanel(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.ConfigurationQuerySuccess,
        clearEvent: Strings.Events.UiEvents.ClearConfiguration,
        ele: $('#configurationList'),
        renderTemplate: uiTemplates.valuePanelTemplate
      }
    )

  registerEventMaps: () ->
    @eventMapper.mapEvent(Strings.Events.UiEvents.EnvironmentSelected, Strings.Events.ServiceCallTriggers.InitiateApplicationQuery)
    @eventMapper.mapEvent(Strings.Events.UiEvents.ApplicationSelected, Strings.Events.ServiceCallTriggers.InitiateScopeQuery)
    @eventMapper.mapEvent(Strings.Events.UiEvents.ScopeSelected, Strings.Events.ServiceCallTriggers.InitiateSettingQuery)
    @eventMapper.mapEvent(Strings.Events.UiEvents.SettingSelected, Strings.Events.ServiceCallTriggers.InitiateConfigurationQuery)
    @eventMapper.mapEvent(Strings.Events.ServiceQueries.ConfigurationQuerySuccess, Strings.Events.ServiceCallTriggers.InitiateAuditingQuery)

  init: () ->
    @logger.debug("CcrAdmin::init")
    window.ccrAdmin.Logger          = @logger
    window.ccrAdmin.EventManager    = @eventManager

    @environmentsList.init()
    @applicationsList.init()
    @scopesList.init()
    @settingsList.init()
    @configurationsPanel.init()

    @registerEventMaps()

    @ccrClientEventWatcher.init()

    @eventManager.dispatchEvents(
      {name: Strings.Events.UiEvents.ClearEnvironments, args: {}},
      {name: Strings.Events.UiEvents.ClearApplications, args: {}},
      {name: Strings.Events.UiEvents.ClearScopes, args: {}},
      {name: Strings.Events.UiEvents.ClearSettings, args: {}},
      {name: Strings.Events.UiEvents.ClearConfiguration, args: {}}
    )
    @eventManager.dispatchEvent(Strings.Events.ServiceCallTriggers.InitiateEnvironmentQuery, {})
