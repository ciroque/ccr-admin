"use strict"

window.MockElement = class MockElement
  constructor: () ->
    @children = []
    @html = ''

  html: (html) ->
    @html = html

  append: (child) ->
    @children.push(child)
