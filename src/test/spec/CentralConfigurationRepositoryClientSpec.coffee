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
  ENVIRONMENTS = ['PROD', 'QA', 'DEV', 'DEFAULT']
  APPLICATIONS = ['WEB', 'DESKTOP', 'SERVICE']

  beforeEach(() ->
    @logSnk = new TestLoggingSink()
    @logger = new Logger({ level: LogLevel.ALL, sink: @logSnk })
    @evtMgr = new EventManager(@logger)
    @client = new CentralConfigurationRepositoryClient(@logger, @evtMgr)
  )

  describe 'buildWebQuery', ->
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
      mockAjaxProvider = new MockAjaxProvider(@logger, { results: ENVIRONMENTS })
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })
      successHandler = (result) -> expect(result).toBe ENVIRONMENTS; successCalled = true
      errorHandler = (error) -> fail("error handler should not have been called!"); errorCalled = true
      webQuery = client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE, successHandler, errorHandler)
      webQuery.execute()
      expect(successCalled).toBe true
      expect(errorCalled).toBe false
      expect(@logSnk.getEventCount()).toBe 3
      expect(@logSnk.getEvents()[2]).toContain("ServiceClient::AjaxCall to #{URL} succeeded")

    it 'dispatches the success event via the event manager', ->
      successEventFired = false
      failedEventFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, { results: ENVIRONMENTS })
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })
      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; successEventFired = true
      @evtMgr.registerHandler(EVT_SUCCESS, successEventHandler)
      failedEventHandler = (args) -> failedEventFired = true
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
      expect(@logSnk.getEventCount()).toBe 3
      expect(@logSnk.getEvents()[2]).toContain("ServiceClient::AjaxCall to #{URL} failed")
      expect(@logSnk.getEvents()[2]).toContain(ERROR_MSG)

    it 'dispatches the failure event via the event manager', ->
      successEventFired = false
      failedEventFired = false

      mockAjaxProvider = new MockAjaxProvider(@logger, { callError: ERROR_MSG })
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })
      successEventHandler = (args) -> successEventFired = true; expect(args).toBe ENVIRONMENTS
      @evtMgr.registerHandler(EVT_SUCCESS, successEventHandler)
      failedEventHandler = (args) -> failedEventFired = true; expect(args).toBe ERROR_MSG
      @evtMgr.registerHandler(EVT_FAILURE, failedEventHandler)
      webQuery = client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE)
      webQuery.execute()
      expect(successEventFired).toBe false
      expect(failedEventFired).toBe true

  describe 'retrieveEnvironments', ->

    it 'handles a successful call to retrieve environments', ->
      environmentQuerySuccessFired = false
      environmentQueryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, { results: ENVIRONMENTS })
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; environmentQuerySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; environmentQueryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQueryFailure, failedEventHandler)

      client.retrieveEnvironments()

      expect(environmentQuerySuccessFired).toBe true
      expect(environmentQueryFailureFired).toBe false

    it 'handles an unsuccessful call to retrieve environments', ->
      environmentQuerySuccessFired = false
      environmentQueryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, { callError: ERROR_MSG })
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; environmentQuerySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; environmentQueryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQueryFailure, failedEventHandler)

      client.retrieveEnvironments()

      expect(environmentQuerySuccessFired).toBe false
      expect(environmentQueryFailureFired).toBe true

  describe 'retrieveApplications', ->
    it 'handles a successful call to retrieve applications', ->
      applicationQuerySuccessFired = false
      applicationQueryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, { results: ENVIRONMENTS })
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; applicationQuerySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; applicationQueryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQueryFailure, failedEventHandler)

      client.retrieveApplications(ENVIRONMENTS[0])

      expect(applicationQuerySuccessFired).toBe true
      expect(applicationQueryFailureFired).toBe false


    it 'handles an unsuccessful call to retrieve applications', ->
      applicationQuerySuccessFired = false
      applicationQueryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, { callError: ERROR_MSG })
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, { lib: mockAjaxProvider })

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; applicationQuerySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; applicationQueryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQueryFailure, failedEventHandler)

      client.retrieveApplications(ENVIRONMENTS[0])

      expect(applicationQuerySuccessFired).toBe false
      expect(applicationQueryFailureFired).toBe true

