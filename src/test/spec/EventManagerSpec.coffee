"use strict"

describe 'EventManager', ->
  EVENT_ONE = "EVENT_ONE"
  EVENT_TWO = "EVENT_TWO"
  EVENT_THREE = "EVENT_THREE"
  @eventManager = null
  @logSink = null
  @logger = null

  beforeEach(() ->
    @logSink = new TestLoggingSink()
    @logger = new Logger({sink: @logSink})
    @eventManager = new EventManager(@logger)
  )

  it 'returns false for an event that is not registered', ->
    expect(@eventManager.isRegistered("NOPE")).toBe false

  it 'allows registering and event and handler', ->
    @eventManager.registerHandler(EVENT_ONE, () -> )
    expect(@eventManager.isRegistered(EVENT_ONE)).toBe true

  it 'calls the handler when a registered event is raised', ->
    called = false
    handler = () -> called = true
    @eventManager.registerHandler(EVENT_ONE, handler)
    expect(called).toBe false
    @eventManager.dispatchEvent(EVENT_ONE, {})
    expect(called).toBe true

  it 'calls multiple handlers for the same event', ->
    firstCalled = false
    secondCalled = false
    firstHandler = () -> firstCalled = true
    secondHandler = () -> secondCalled = true
    expect(firstCalled).toBe false
    expect(secondCalled).toBe false
    @eventManager.registerHandler(EVENT_ONE, firstHandler)
    @eventManager.registerHandler(EVENT_ONE, secondHandler)
    @eventManager.dispatchEvent(EVENT_ONE, {})
    expect(firstCalled).toBe true
    expect(secondCalled).toBe true

  it 'calls multiple handlers for the same event, but not other event handlers', ->
    firstCalled = false
    secondCalled = false
    thirdCalled = false
    fourthCalled = false
    firstHandler = () -> firstCalled = true
    secondHandler = () -> secondCalled = true
    thirdHandler = () -> thirdCalled = true
    fourthHandler = () -> fourthCalled = true
    expect(firstCalled).toBe false
    expect(secondCalled).toBe false
    expect(thirdCalled).toBe false
    expect(fourthCalled).toBe false
    @eventManager.registerHandler(EVENT_ONE, firstHandler)
    @eventManager.registerHandler(EVENT_ONE, secondHandler)
    @eventManager.registerHandler(EVENT_TWO, thirdHandler)
    @eventManager.registerHandler(EVENT_THREE, fourthHandler)
    @eventManager.dispatchEvent(EVENT_ONE, {})
    expect(firstCalled).toBe true
    expect(secondCalled).toBe true
    expect(thirdCalled).toBe false
    expect(fourthCalled).toBe false

  it 'passes the arguments through to he handler', ->
    expectedArgs = {option1: 1, option2: 2}
    actualArgs = null
    handler = (args) -> actualArgs = args
    @eventManager.registerHandler(EVENT_ONE, handler)
    @eventManager.dispatchEvent(EVENT_ONE, expectedArgs)
    expect(actualArgs).toBe expectedArgs
