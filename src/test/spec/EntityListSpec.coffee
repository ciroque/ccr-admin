"use strict"

describe 'EntityList', ->

  POPULATE_EVENT = "TPE"
  MST_TEMPLATE = 'And the winner is: {{name}}'

  @logSink = null
  @logger = null
  @eventMgr = null
  @uiTemplates = null
  @ele = null
  @entityList = null

  beforeEach(() ->
    Mustache.parse(MST_TEMPLATE)
    @logSink = new TestLoggingSink()
    @logger = new Logger({level: LogLevel.ALL, sink: @logSink})
    @eventMgr = new EventManager(@logger)
    @ele = new MockElement()

    @uiTemplates = new UiTemplates()
    @uiTemplates.init()
  )

  it 'accepts an Event Name and appends the template to the given element when the event is raised - environments', ->
    opts = {
      populateEvent: POPULATE_EVENT,
      ele: @ele,
      template: MST_TEMPLATE
    }
    @entityList = new EntityList(@logger, @eventMgr, opts)
    @entityList.init()
    @eventMgr.dispatchEvent(POPULATE_EVENT, {environments: ['Noah']})
    expect(@ele.children[0]).toBe 'And the winner is: Noah'

  it 'accepts an Event Name and appends the template to the given element when the event is raised - applications', ->
    opts = {
      populateEvent: POPULATE_EVENT,
      ele: @ele,
      template: MST_TEMPLATE
    }
    @entityList = new EntityList(@logger, @eventMgr, opts)
    @entityList.init()
    @eventMgr.dispatchEvent(POPULATE_EVENT, {applications: ['Noah']})
    expect(@ele.children[0]).toBe 'And the winner is: Noah'

  it 'accepts an Event Name and appends the template to the given element when the event is raised - scopes', ->
    opts = {
      populateEvent: POPULATE_EVENT,
      ele: @ele,
      template: MST_TEMPLATE
    }
    @entityList = new EntityList(@logger, @eventMgr, opts)
    @entityList.init()
    @eventMgr.dispatchEvent(POPULATE_EVENT, {scopes: ['Noah']})
    expect(@ele.children[0]).toBe 'And the winner is: Noah'

  it 'accepts an Event Name and appends the template to the given element when the event is raised - settings', ->
    opts = {
      populateEvent: POPULATE_EVENT,
      ele: @ele,
      template: MST_TEMPLATE
    }
    @entityList = new EntityList(@logger, @eventMgr, opts)
    @entityList.init()
    @eventMgr.dispatchEvent(POPULATE_EVENT, {settings: ['Noah']})
    expect(@ele.children[0]).toBe 'And the winner is: Noah'

  it 'accepts an Event Name and appends the template to the given element when the event is raised - unknown', ->
    opts = {
      populateEvent: POPULATE_EVENT,
      ele: @ele,
      template: MST_TEMPLATE
    }
    @entityList = new EntityList(@logger, @eventMgr, opts)
    @entityList.init()
    @eventMgr.dispatchEvent(POPULATE_EVENT, {unknown: ['Noah']})
    expect(@ele.children.length).toBe 0

  it 'produces a list of items based on the actual template', ->
    populateEvent = 'REAL_TEMPLATE'
    opts = {
      populateEvent: populateEvent,
      ele: @ele,
      template: @uiTemplates.listItemTemplate
    }
    entityList = new EntityList(@logger, @eventMgr, opts)
    entityList.init()

    @eventMgr.dispatchEvent(populateEvent, { environments: ['Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah'] })
    expect(@ele.children[0]).toContain('Hosea')
    expect(@ele.children[1]).toContain('Joel')
    expect(@ele.children[2]).toContain('Amos')
    expect(@ele.children[3]).toContain('Obadiah')
    expect(@ele.children[4]).toContain('Jonah')

  it 'accepts a clear event and clears its contents when received', ->
    populateEvent = 'FILL'
    clearEvent = 'EMPTY'
    opts = {
      populateEvent: populateEvent,
      clearEvent: clearEvent,
      ele: @ele,
      template: MST_TEMPLATE
    }
    entityList = new EntityList(@logger, @eventMgr, opts)
    entityList.init()

    @eventMgr.dispatchEvent(populateEvent, { environments: ['Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah'] })
    expect(@ele.children.length).toBe 5

    @eventMgr.dispatchEvent(clearEvent, {})
    expect(@ele.children.length).toBe 0
