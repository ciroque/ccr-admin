"use strict"

window.ValuesPanel = class ValuesPanel
  constructor: (@logger, @eventManager, opts = {}) ->
    @opts = AppTools.merge({renderTemplate: null, clearEvent: null, populateEvent: null, ele: null}, opts)

  init: () ->
    @logger.debug("ValuesPanel::init")
    @registerHandlers()

  registerHandlers: () ->
    template = @opts.renderTemplate
    parentEle = @opts.ele

    appendToEle = (item) ->
      el = Mustache.render(template, item)
      parentEle.append(el)

    @eventManager.registerHandler(@opts.populateEvent, (items) ->
      appendToEle item for item in items.configuration
    )

    @eventManager.registerHandler(@opts.clearEvent, () -> parentEle.empty())
