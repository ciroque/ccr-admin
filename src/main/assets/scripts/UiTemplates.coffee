"use strict"

window.UiTemplates = class UiTemplates
  constructor: () ->
    @listItemTemplate = $('#listItem-mst').html()
    @valuePanelTemplate = $('#valuePanel-mst').html()

  init: () ->
    Mustache.parse(@listItemTemplate)
    Mustache.parse(@valuePanelTemplate)
