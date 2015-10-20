"use strict"

window.EventMapper = class EventMapper
  constructor: (@logger, @eventManager, opts = {}) ->
    @opts = AppTools.merge({ eventMap: [] }, opts)

  init: () ->
    @registerEventHandlers()

  registerEventHandlers: () ->
    @mapEvent(map.rcv, map.send) for map in @opts.eventMap

  mapEvent: (from, to) ->
    eventManager = @eventManager
    eventManager.registerHandler(from, (args) -> eventManager.dispatchEvent(to, args))