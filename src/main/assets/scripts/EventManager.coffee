class EventManager
  constructor: (@logger) ->
    @handlerMap = []

  registerHandler: (name, handler) ->
    @handlerMap[name] = [] if !@handlerMap[name]
    @handlerMap[name].push(handler)
    @

  isRegistered: (name) ->
    @handlerMap[name] && true
