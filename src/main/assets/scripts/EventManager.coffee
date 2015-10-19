"use strict"

window.EventManager = class EventManager
  constructor: (@logger) ->
    @handlerMap = []

  registerHandler: (name, handler) ->
    @handlerMap[name] = [] if !@handlerMap[name]
    @handlerMap[name].push(handler)
    @

  isRegistered: (name) ->
    @handlerMap[name] != undefined

  dispatchEvent: (name, args) ->
    @logger.debug("EventManager::dispatchEvent(#{name}, #{args})")
    handlers = if @handlerMap[name] then @handlerMap[name] else []
    handler args for handler in handlers when handlers?
    @
