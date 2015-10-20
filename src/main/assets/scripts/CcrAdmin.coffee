"use strict"

window.CcrAdmin = class CcrAdmin
  constructor: () ->
    @logger = new Logger({level: LogLevel.ALL})
    @eventManager = new EventManager(@logger)
    @eventMapper = new EventMapper(@logger, @eventManager)
    @ccrClient = new CentralConfigurationRepositoryClient(@logger, @eventManager, { ccrService: { protocol: 'http', host: 'localhost', port: 35487 } })
    uiTemplates = new UiTemplates()
    uiTemplates.init()
    @environmentsList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.EnvironmentQuerySuccess,
        ele: $('#environmentsList'),
        template: uiTemplates.listItemTemplate
      })
    @applicationsList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.ApplicationQuerySuccess,
        ele: $('#applicationsList'),
        template: uiTemplates.listItemTemplate
      })
    @scopesList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.ScopeQuerySuccess,
        ele: $('#scopesList'),
        template: uiTemplates.listItemTemplate
      })
    @settingsList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.SettingQuerySuccess,
        ele: $('#settingsList'),
        template: uiTemplates.listItemTemplate
      })

  registerEventMaps: () ->
    @eventMapper.mapEvent(Strings.Events.UiEvents.EnvironmentSelected, Strings.Events.ServiceCallTriggers.InitiateApplicationQuery)
    @eventMapper.mapEvent(Strings.Events.UiEvents.ApplicationSelected, Strings.Events.ServiceCallTriggers.InitiateScopeQuery)
    @eventMapper.mapEvent(Strings.Events.UiEvents.ScopeSelected, Strings.Events.ServiceCallTriggers.InitiateSettingQuery)
    @eventMapper.mapEvent(Strings.Events.UiEvents.SettingSelected, Strings.Events.ServiceCallTriggers.InitiateConfigurationQuery)

  init: () ->
    @logger.debug("CcrAdmin::init #{JSON.stringify(@ccrClient.opts)}")
    window.ccrAdmin.Logger          = @logger
    window.ccrAdmin.EventManager    = @eventManager
    @environmentsList.init()
    @applicationsList.init()
    @scopesList.init()
    @settingsList.init()

    @registerEventMaps()
