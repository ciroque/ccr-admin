"use strict"

window.CcrAdmin = class CcrAdmin
  constructor: () ->
    @logger = new Logger({level: LogLevel.ALL})
    @eventManager = new EventManager(@logger)
    @ccrClient = new CentralConfigurationRepositoryClient(@logger, @eventManager, { ccrService: { protocol: 'http', host: 'localhost', port: 35487 } })
    uiTemplates = new UiTemplates()
    uiTemplates.init()
    @environmentList = new EntityList(
      @logger,
      @eventManager,
      {
        populateEvent: Strings.Events.ServiceQueries.EnvironmentQuerySuccess,
        ele: $('#environmentList'),
        template: uiTemplates.listItemTemplate
      })


  init: () ->
    @logger.debug("CcrAdmin::init #{JSON.stringify(@ccrClient.opts)}")
    @environmentList.init()
    @ccrClient.retrieveEnvironments()
#    @ccrClient.retrieveApplications('PROD')
#    @ccrClient.retrieveScopes('PROD', 'CCR-ADMIN')
#    @ccrClient.retrieveSettings('PROD', 'CCR-ADMIN', 'LOGGING')
#    @ccrClient.retrieveConfigurations('PROD', 'CCR-ADMIN', 'LOGGING', 'LOGFILENAME')

