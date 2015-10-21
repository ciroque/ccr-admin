"use strict"

window.Presentation = class Presentation
  constructor: () ->
    @positionTemplate = $('#nfl-position-mst').html()
    @logger = new window.Logger({level: LogLevel.ALL})
    @eventManager = new window.EventManager(@logger)
    @ccrClient = new window.CentralConfigurationRepositoryClient(@logger, @eventManager)

  init: () ->
    @logger.debug('Presentation::init')
    Mustache.parse(@positionTemplate)

  registerEventHandlers: () ->
    setPosition = @setPosition
    @eventManager.registerHandler(
      Strings.Events.ServiceQueries.ConfigurationQuerySuccess,
      (cfgs) ->
        cfg = cfgs[0]
        position = cfg.key.setting
        data = { name: cfg.value, ttl: cfg.temporality.ttl, cacheHit: false }
        @logger.debug("HANDLING: #{position} :: #{JSON.stringify(data)}")
        setPosition(position, data)
    )

  setPosition: (elId, data) ->
    @logger.debug("Presentation::setPosition")
    rendered = Mustache.render(@positionTemplate, data)
    $("##{elId}").html(rendered)

  loadPositions: () ->
    @ccrClient.retrieveConfigurations('NFL', 'Seahawks', 'Offense', position) for position in Seahawks.POSITIONS

  run: () ->
    @init()
    @loadPositions()
