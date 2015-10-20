"use strict"

describe 'ValuesPanel', ->
  POPULATE_EVENT = 'TSTVLSPNL'
  RENDER_TEMPLATE = '{{value}}, {{sourceId}}, {{effectiveAt}}, {{expiresAt}}, {{ttl}}'
  EVENT_ARGS = {
    "configuration": [
      {"_id": "a7a48f32-76bc-11e5-8bcf-feff819cdc91", "key": {"environment": "PROD", "application": "CCR-SERVICE", "scope": "AKKA", "setting": "LOGFILENAME"}, "value": "ccr-admin.log", "temporality": {"effectiveAt": "2015-01-01T00:00:00.000-08:00", "expiresAt": "2015-12-31T00:00:00.000-08:00", "ttl": 20}},
      {"_id": "a7a48f32-76bc-11e5-8bcf-feff819cdc92", "key": {"environment": "PROD", "application": "CCR-SERVICE", "scope": "AKKA", "setting": "LOGFILENAME"}, "value": "ccr-admin.log", "temporality": {"effectiveAt": "2015-01-01T00:00:00.000-08:00", "expiresAt": "2015-12-31T00:00:00.000-08:00", "ttl": 20}}
    ]
  }

  beforeEach(() ->
    @logSink = new TestLoggingSink()
    @logger = new Logger({level: LogLevel.ALL, sink: @logSink})
    @eventManager = new EventManager(@logger)
    @ele = new MockElement()
  )

  it 'reacts to a Configuration Query Success event and renders to the given template', ->
    valuesPanel = new ValuesPanel(@logger, @eventManager, {renderTemplate: RENDER_TEMPLATE, populateEvent: POPULATE_EVENT, ele: @ele})
    @eventManager.dispatchEvent(POPULATE_EVENT, EVENT_ARGS)
    expect(@ele.children.length).toBe 1
