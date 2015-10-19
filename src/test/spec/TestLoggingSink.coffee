window.TestLoggingSink = class TestLoggingSink
  @events = null
  constructor: () ->
    @events = []
  log: (msg) ->
    @events.push(msg)
  getEvents: () ->
    clone = (o) ->
      c = {}
      for k of o
        c[k] = o[k]
      c
    clone(@events)
  getEventCount: () ->
    @events.length
