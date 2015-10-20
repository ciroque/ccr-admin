"use strict"

window.MockElement = class MockElement
  constructor: () ->
    @children = []
    @html = ''

  html: (html) ->
    @html = html

  append: (child) ->
    @children.push(child)

  executeChild: (index) ->
    @children[index] if @children[index]

  dumpChildren: () ->
    console.log("#{i}) #{child}") for child, i in @children