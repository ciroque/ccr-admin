"use strict"

describe "CentralConfigurationRepositoryClient", ->
  @logSnk = null
  @logger = null
  @evtMgr = null
  @client = null

  URL = 'http://localhost:80/ccr/setting'
  EVT_SUCCESS = 'TestSuccessfulEvent'
  EVT_FAILURE = 'TestFailedEvent'
  ERROR_MSG = "THIS IS A FAILURE MESSAGE"

  beforeEach(() ->
    @logSnk = new TestLoggingSink()
    @logger = new Logger({ level: LogLevel.ALL, sink: @logSnk })
    @evtMgr = new EventManager()
    @client = new CentralConfigurationRepositoryClient(@logger, @evtMgr)
  )

  it 'builds a web query object', ->
    webQuery = @client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE)
    expect(webQuery.lib).toBe $
    expect(webQuery.url).toBe URL
    expect(webQuery.logger).toBe @logger
    expect(webQuery.eventManager).toBe @evtMgr
    expect(webQuery.success).toBeDefined()
    expect(webQuery.fail).toBeDefined()
    expect(webQuery.execute).toBeDefined()

  it 'calls the provided success handler with the appropriate arguments', ->
    successCalled = false
    errorCalled = false
    resultsToReturn = ['PROD', 'QA', 'DEV', 'DEFAULT']
    mockAjaxProvider = new MockAjaxProvider(@logger, { results: resultsToReturn })
    client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })
    successHandler = (result) -> expect(result).toBe resultsToReturn; successCalled = true
    errorHandler = (error) -> fail("error handler should not have been called!"); errorCalled = true
    webQuery = client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE, successHandler, errorHandler)
    webQuery.execute()
    expect(successCalled).toBe true
    expect(errorCalled).toBe false
    expect(@logSnk.getEventCount()).toBe 2
    expect(@logSnk.getEvents()[1]).toContain("ServiceClient::AjaxCall to #{URL} succeeded")

  it 'dispatches the success event via the event manager', ->
    successEventFired = false
    failedEventFired = false
    resultsToReturn = ['PROD', 'QA', 'DEV', 'DEFAULT']
    mockAjaxProvider = new MockAjaxProvider(@logger, { results: resultsToReturn })
    client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })
    successEventHandler = (args) -> expect(args).toBe resultsToReturn; console.log("successEventHandler: #{args}"); successEventFired = true
    @evtMgr.registerHandler(EVT_SUCCESS, successEventHandler)
    failedEventHandler = (args) -> console.log("failedEventHandler: #{args}"); failedEventFired = true
    @evtMgr.registerHandler(EVT_FAILURE, failedEventHandler)
    webQuery = client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE)
    webQuery.execute()
    expect(successEventFired).toBe true
    expect(failedEventFired).toBe false

  it 'calls the provided error handler with the appropriate arguments', ->
    successCalled = false
    errorCalled = false
    mockAjaxProvider = new MockAjaxProvider(@logger, { callError: ERROR_MSG })
    client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })
    successHandler = () -> fail("success handler should not have been called!"); successCalled = true
    errorHandler = (error) -> expect(error).toBe ERROR_MSG; errorCalled = true
    webQuery = client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE, successHandler, errorHandler)
    webQuery.execute()
    expect(successCalled).toBe false
    expect(errorCalled).toBe true
    expect(@logSnk.getEventCount()).toBe 2
    expect(@logSnk.getEvents()[1]).toContain("ServiceClient::AjaxCall to #{URL} failed")
    expect(@logSnk.getEvents()[1]).toContain(ERROR_MSG)

  it 'dispatches the failure event via the event manager', ->
    successEventFired = false
    failedEventFired = false
    resultsToReturn = ['PROD', 'QA', 'DEV', 'DEFAULT']
    mockAjaxProvider = new MockAjaxProvider(@logger, { callError: ERROR_MSG })
    client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })
    successEventHandler = (args) -> expect(args).toBe resultsToReturn; console.log("successEventHandler: #{args}"); successEventFired = true
    @evtMgr.registerHandler(EVT_SUCCESS, successEventHandler)
    failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; failedEventFired = true
    @evtMgr.registerHandler(EVT_FAILURE, failedEventHandler)
    webQuery = client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE)
    webQuery.execute()
    expect(successEventFired).toBe false
    expect(failedEventFired).toBe true
