window.CcrAdmin = class CcrAdmin
  constructor: () ->
    @logger = new Logger({level: LogLevel.ALL})
    @eventManager = new EventManager(@logger)
    @ccrClient = new CentralConfigurationRepositoryClient(@logger, @eventManager)

  init: () ->
    @logger.debug('CcrAdmin::init')

ccrAdmin = new CcrAdmin()
ccrAdmin.init()
