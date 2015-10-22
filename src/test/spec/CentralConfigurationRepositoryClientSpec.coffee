"use strict"

describe "CentralConfigurationRepositoryClient", ->
  @logSnk = null
  @logger = null
  @evtMgr = null
  @client = null

  TODAY = new Date()
  YESTERDAY = new Date().setDate(TODAY.getDate() - 1)
  TOMORROW = new Date().setDate(TODAY.getDate() + 1)
  URL = 'http://54.187.190.215:35487/ccr/settings/'
  EVT_SUCCESS = 'TestSuccessfulEvent'
  EVT_FAILURE = 'TestFailedEvent'
  ERROR_MSG = "THIS IS A FAILURE MESSAGE"
  ENVIRONMENTS = ['PROD', 'QA', 'DEV', 'DEFAULT']
  APPLICATIONS = ['WEB', 'DESKTOP', 'SERVICE']
  SCOPES = ['LOGGING', 'BL']
  SETTINGS = ['LOGFILENAME', 'LOGLEVEL', 'ROLLINTERVAL']
  CONFIGURATIONS = {
    configuration: [{
      key: {
        environment: ENVIRONMENTS[0],
        application: APPLICATIONS[0],
        scope: SCOPES[0],
        setting: SETTINGS[0],
        sourceId: "BOOM"
      },
      value: 'YAYHOO',
      temporality: {
        effectiveAt: YESTERDAY,
        expiresAt: TOMORROW,
        ttl: 1
      }
    }]
  }

  beforeEach(() ->
    @logSnk = new TestLoggingSink()
    @logger = new Logger({level: LogLevel.ALL, sink: @logSnk})
    @evtMgr = new EventManager(@logger)
    @client = new CentralConfigurationRepositoryClient(@logger, @evtMgr)
  )

  describe 'buildWebQuery', ->
    it 'builds a web query object', ->
      webQuery = @client.buildWebQuery("", EVT_SUCCESS, EVT_FAILURE)
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
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: ENVIRONMENTS})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})
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
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: ENVIRONMENTS})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})
      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; successEventFired = true
      @evtMgr.registerHandler(EVT_SUCCESS, successEventHandler)
      failedEventHandler = () -> failedEventFired = true
      @evtMgr.registerHandler(EVT_FAILURE, failedEventHandler)
      webQuery = client.buildWebQuery(URL, EVT_SUCCESS, EVT_FAILURE)
      webQuery.execute()
      expect(successEventFired).toBe true
      expect(failedEventFired).toBe false

    it 'calls the provided error handler with the appropriate arguments', ->
      successCalled = false
      errorCalled = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})
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

      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})
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
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: ENVIRONMENTS})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQueryFailure, failedEventHandler)

      client.retrieveEnvironments()

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/setting")

    it 'handles an unsuccessful call to retrieve environments', ->
      environmentQuerySuccessFired = false
      environmentQueryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; environmentQuerySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; environmentQueryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.EnvironmentQueryFailure, failedEventHandler)

      client.retrieveEnvironments()

      expect(environmentQuerySuccessFired).toBe false
      expect(environmentQueryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/setting")

  describe 'retrieveApplications', ->
    it 'handles a successful call to retrieve applications', ->
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: ENVIRONMENTS})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQueryFailure, failedEventHandler)

      client.retrieveApplications(ENVIRONMENTS[0])

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}")

    it 'handles an unsuccessful call to retrieve applications', ->
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe ENVIRONMENTS; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ApplicationQueryFailure, failedEventHandler)

      client.retrieveApplications(ENVIRONMENTS[0])

      expect(querySuccessFired).toBe false
      expect(queryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}")

  describe 'retrieveScopes', ->
    it 'handles a successful call to retrieve scopes', ->
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: SCOPES})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe SCOPES; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ScopeQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ScopeQueryFailure, failedEventHandler)

      client.retrieveScopes(ENVIRONMENTS[0], APPLICATIONS[0])

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}")

    it 'handles an unsuccessful call to retrieve scopes', ->
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe SCOPES; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ScopeQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ScopeQueryFailure, failedEventHandler)

      client.retrieveScopes(ENVIRONMENTS[0], APPLICATIONS[0])

      expect(querySuccessFired).toBe false
      expect(queryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}")

  describe 'retrieveSettings', ->
    it 'handles a successful call to retrieve settings', ->
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: SETTINGS})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe SETTINGS; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.SettingQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.SettingQueryFailure, failedEventHandler)

      client.retrieveSettings(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0])

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}")

    it 'handles an unsuccessful call to retrieve settings', ->
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe SETTINGS; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.SettingQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.SettingQueryFailure, failedEventHandler)

      client.retrieveSettings(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0])

      expect(querySuccessFired).toBe false
      expect(queryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}")

  describe 'retrieveConfigurations', ->
    it 'handles a successful call to retrieve configurations', ->
      querySuccessFired = false
      queryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: CONFIGURATIONS})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe CONFIGURATIONS; querySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ConfigurationQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ConfigurationQueryFailure, failedEventHandler)

      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0])

      expect(querySuccessFired).toBe true
      expect(queryFailureFired).toBe false
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}/#{SETTINGS[0]}")

    it 'handles an unsuccessful call to retrieve configurations', ->
      scopeQuerySuccessFired = false
      scopeQueryFailureFired = false
      mockAjaxProvider = new MockAjaxProvider(@logger, {callError: ERROR_MSG})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args).toBe CONFIGURATIONS; scopeQuerySuccessFired = true
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; scopeQueryFailureFired = true

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ConfigurationQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ConfigurationQueryFailure, failedEventHandler)

      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0])

      expect(scopeQuerySuccessFired).toBe false
      expect(scopeQueryFailureFired).toBe true
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}/#{SETTINGS[0]}")

    it 'uses the cache for settings', ->
      querySuccessFired = 0
      queryFailureFired = 0
      mockAjaxProvider = new MockAjaxProvider(@logger, {results: CONFIGURATIONS})
      client = new CentralConfigurationRepositoryClient(@logger, @evtMgr, {lib: mockAjaxProvider})

      successEventHandler = (args) -> expect(args[0]).toBe CONFIGURATIONS[0]; querySuccessFired++
      failedEventHandler = (args) -> expect(args).toBe ERROR_MSG; queryFailureFired++

      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ConfigurationQuerySuccess, successEventHandler)
      @evtMgr.registerHandler(Strings.Events.ServiceQueries.ConfigurationQueryFailure, failedEventHandler)

      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0])
      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0])
      Utils.sleep(1001)
      client.retrieveConfigurations(ENVIRONMENTS[0], APPLICATIONS[0], SCOPES[0], SETTINGS[0])

      cacheStats = client.cache.getStats()

      expect(querySuccessFired).toBe 3
      expect(queryFailureFired).toBe 0
      expect(@logSnk.getEvents()[1]).toContain("/ccr/settings/#{ENVIRONMENTS[0]}/#{APPLICATIONS[0]}/#{SCOPES[0]}/#{SETTINGS[0]}")
      expect(cacheStats.cacheAttempts).toBe 3
      expect(cacheStats.cacheHits).toBe 1
      expect(cacheStats.cacheMisses).toBe 1
      expect(cacheStats.cacheExpiries).toBe 1
