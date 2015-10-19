"use strict"

describe "CentralConfigurationRepositoryClient", ->
  @logSnk = null
  @logger = null
  @evtMgr = null
  @client = null


  beforeEach: () ->
    @logSnk = new TestLoggingSink()
    @logger = new Logger({ level: LogLevel.ALL, sink: @logSnk })
    @evtMgr = new EventManager()
    @client = new CentralConfigurationRepositoryClient(@logger, @evtMgr)

  it 'builds a web query object', ->
    URL = "http://localhost:80/ccr/setting"
    EVT_SUCCESS = "SuccessfulEvent"
    EVT_FAILURE = "Failed`Event"
    webQuery = @client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE)
    webQuery