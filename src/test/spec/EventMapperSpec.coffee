"use strict"

describe 'EventMapper', ->

  POPULATE_LIST_ONE_EVENT = 'PL1'
  POPULATE_LIST_TWO_EVENT = 'PL2'
  POPULATE_LIST_THREE_EVENT = 'PL3'

  LIST_ONE_ITEM_SELECTED_EVENT = 'L1IS'
  LIST_TWO_ITEM_SELECTED_EVENT = 'L2IS'
  LIST_THREE_ITEM_SELECTED_EVENT = 'L3IS'

  LIST_ONE_TEMPLATE = "('{{evt}}', { value: '{{name}}' })"
  LIST_TWO_TEMPLATE = LIST_ONE_TEMPLATE
  LIST_THREE_TEMPLATE = LIST_ONE_TEMPLATE

  ENVIRONMENTS = ['One', 'Two', 'Three']

  @listOne = null
  @listTwo = null
  @listThree = null

  @eleOne = null
  @eleTwo = null
  @eleThree = null

  @entityListManager = null

  @logSink = null
  @logger = null
  @eventManager = null

  beforeEach(() ->
    @logSink = new TestLoggingSink()
    @logger = new Logger({level: LogLevel.ALL, sink: @logSink})
    @eventManager = new EventManager(@logger)

    @eleOne = new MockElement()
    @eleTwo = new MockElement()
    @eleThree = new MockElement()

    @listOne = new EntityList(@logger, @eventManager, { populateEvent: POPULATE_LIST_ONE_EVENT, ele: @eleOne, template: LIST_ONE_TEMPLATE })
    @listTwo = new EntityList(@logger, @eventManager, { populateEvent: POPULATE_LIST_TWO_EVENT, ele: @eleTwo, template: LIST_TWO_TEMPLATE })
    @listThree = new EntityList(@logger, @eventManager, { populateEvent: POPULATE_LIST_THREE_EVENT, ele: @eleThree, template: LIST_THREE_TEMPLATE })

    @listOne.init()
    @listTwo.init()
    @listThree.init()

    eventMap = {
      eventMap: [
        { rcv: LIST_ONE_ITEM_SELECTED_EVENT, send: POPULATE_LIST_TWO_EVENT },
        { rcv: LIST_TWO_ITEM_SELECTED_EVENT, send: POPULATE_LIST_THREE_EVENT }
      ]
    }

    @eventMapper = new EventMapper(@logger, @eventManager, eventMap)
    @eventMapper.init()
  )

  it 'dispatches a load list two event when a list one item selected event is received', ->
    populateListTwoEventRaised = false
    handlePopulateListTwoEventHandler = () -> populateListTwoEventRaised = true
    @eventManager.registerHandler(POPULATE_LIST_TWO_EVENT, handlePopulateListTwoEventHandler)
    @eventManager.dispatchEvent(POPULATE_LIST_ONE_EVENT, { environments: ENVIRONMENTS })
    @eventManager.dispatchEvent(LIST_ONE_ITEM_SELECTED_EVENT, { value: ENVIRONMENTS[1] })
    expect(populateListTwoEventRaised).toBe true

  it 'dispatches a load list three event when a list two item selected event is received', ->
    populateListThreeEventRaised = false
    handlePopulateListThreeEventHandler = () -> populateListThreeEventRaised = true
    @eventManager.registerHandler(POPULATE_LIST_THREE_EVENT, handlePopulateListThreeEventHandler)
    @eventManager.dispatchEvent(POPULATE_LIST_TWO_EVENT, { environments: ENVIRONMENTS })
    @eventManager.dispatchEvent(LIST_TWO_ITEM_SELECTED_EVENT, { value: ENVIRONMENTS[1] })
    expect(populateListThreeEventRaised).toBe true

  it 'dispatches a series of events in response to triggering events', ->
    populateListTwoEventRaised = false
    populateListThreeEventRaised = false

    handlePopulateListTwoEventHandler = () -> populateListTwoEventRaised = true
    handlePopulateListThreeEventHandler = () -> populateListThreeEventRaised = true

    @eventManager.registerHandler(POPULATE_LIST_TWO_EVENT, handlePopulateListTwoEventHandler)
    @eventManager.registerHandler(POPULATE_LIST_THREE_EVENT, handlePopulateListThreeEventHandler)

    @eventManager.dispatchEvent(POPULATE_LIST_ONE_EVENT, { environments: ENVIRONMENTS })
    @eventManager.dispatchEvent(POPULATE_LIST_TWO_EVENT, { environments: ENVIRONMENTS })

    @eventManager.dispatchEvent(LIST_ONE_ITEM_SELECTED_EVENT, { value: ENVIRONMENTS[0] })
    @eventManager.dispatchEvent(LIST_TWO_ITEM_SELECTED_EVENT, { value: ENVIRONMENTS[1] })

    expect(populateListTwoEventRaised).toBe true
    expect(populateListThreeEventRaised).toBe true

  it 'allows mapping two events via method call in addition to constructor opts', ->
    PRIME_EVENT = 'EVENT_PRIME'
    SUBSEQUENT_EVENT = 'SUBSEQUENT_EVENT'
    ARGS = { cool: true }
    subsequentEventFired = false
    subsequentEventHandler = (args) -> expect(args).toBe ARGS; subsequentEventFired = true
    @eventManager.registerHandler(SUBSEQUENT_EVENT, subsequentEventHandler)
    @eventMapper.mapEvent(PRIME_EVENT, SUBSEQUENT_EVENT)
    @eventManager.dispatchEvent(PRIME_EVENT, ARGS)
    expect(subsequentEventFired).toBe true