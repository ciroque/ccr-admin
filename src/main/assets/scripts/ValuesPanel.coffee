"use strict"

window.ValuesPanel = class ValuesPanel
  constructor: (@logger, @eventManager, opts = {}) ->
    @opts = AppTools.merge({}, opts)

  init: () ->
    @logger.debug("ValuesPanel::init")
