"use strict"

window.CcrAdmin = class CcrAdmin
  constructor: () ->
    @logger = new Logger({level: LogLevel.ALL})
    @eventManager = new EventManager(@logger)
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


  init: () ->
    @logger.debug("CcrAdmin::init #{JSON.stringify(@ccrClient.opts)}")
    window.ccrAdmin.Logger          = @logger
    window.ccrAdmin.EventManager    = @eventManager
    @environmentsList.init()
    @applicationsList.init()
    @scopesList.init()
    @settingsList.init()

    @ccrClient.retrieveEnvironments()

      ## TODO : Remove these as the eventing goes into place.
    @ccrClient.retrieveApplications('*')
    @ccrClient.retrieveScopes('*', '*')
    @ccrClient.retrieveSettings('*', '*', '*')
#    @ccrClient.retrieveConfigurations('PROD', 'CCR-ADMIN', 'LOGGING', 'LOGFILENAME')

