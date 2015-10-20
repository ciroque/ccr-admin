"use strict"

window.EntityList = class EntityList
  constructor: (@logger, @eventMgr, opts = {}) ->
    @opts = AppTools.merge({ populateEvent: null, clearEvent: null, ele: null, template: null }, opts)

  init: () ->
    @logger.debug('EntityList::init')
    @registerHandlers()

  registerHandlers: () ->
    parentEle = @opts.ele
    template = @opts.template
    logger = @logger

    populateHandler = (items) ->
      logger.debug("EntityList::populateHandler(#{JSON.stringify(items)})")

      extractList = (items) ->
        if items.environments
          {name: item, evt: Strings.Events.UiEvents.EnvironmentSelected } for item in items.environments
        else if items.applications
          {name: item, evt: Strings.Events.UiEvents.ApplicationSelected, env: items.environment } for item in items.applications
        else if items.scopes
          {name: item, evt: Strings.Events.UiEvents.ScopeSelected, env: items.environment, app: items.application } for item in items.scopes
        else if items.settings
          {name: item, evt: Strings.Events.UiEvents.SettingSelected, env: items.environment, app: items.application, scp: items.scope } for item in items.settings
        else
          []

      appendToEle = (item) ->
        el = Mustache.render(template, item)
        parentEle.append(el)

      appendToEle(item) for item in extractList(items)

    @eventMgr.registerHandler(@opts.populateEvent, populateHandler)
    @eventMgr.registerHandler(@opts.clearEvent, () -> parentEle.empty())