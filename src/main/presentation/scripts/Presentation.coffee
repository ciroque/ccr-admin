"use strict"

window.Presentation = class Presentation
  constructor: () ->
    @positionTemplate = $('#nfl-position-mst').html()
    @cacheStatsTemplate = $('#cache-stats-mst').html()
    @logger = new window.Logger({level: LogLevel.ALL})
    @eventManager = new window.EventManager(@logger)
    @ccrClient = new window.CentralConfigurationRepositoryClient(@logger, @eventManager)

  init: () ->
    @logger.debug('Presentation::init')
    Mustache.parse(@positionTemplate)
    Mustache.parse(@cacheStatsTemplate)
    window.positionTemplate = @positionTemplate
    @registerEventHandlers()

  registerEventHandlers: () ->
    setPosition = @setPosition
    logger = @logger
    @eventManager.registerHandler(
      Strings.Events.ServiceQueries.ConfigurationQuerySuccess,
      (cfgs) ->
        cfg = cfgs.configuration[0]
        position = cfg.key.setting
        secondsUntilExpiration = (new Date(cfg.temporality.expiresAt).getTime() - new Date().getTime()) / 1000
        data = {
          name: cfg.value,
          ttl: cfg.temporality.ttl,
          cacheHit: cfgs.cacheHit,
          position: position.substr(8),
          willSub: if secondsUntilExpiration > 200 then 0 else parseInt(secondsUntilExpiration)
        }
        logger.debug(JSON.stringify(cfgs))
        setPosition(position, data)
    )

  setPosition: (elId, data) ->
    rendered = Mustache.render(window.positionTemplate, data)
    $("##{elId}").html(rendered)

  loadPositions: () ->
    @ccrClient.retrieveConfigurations(
      Seahawks.ENVIRONMENT,
      Seahawks.APPLICATION,
      Seahawks.SCOPE,
      position) for position in Seahawks.OFFENSIVE_POSITIONS
    @updateCacheStats()

  updateCacheStats: () ->
    stats = @ccrClient.cache.getStats()
    $('#cacheStats').html(Mustache.render(@cacheStatsTemplate, stats))
#    console.log("CacheStats :: #{JSON.stringify(stats)}")

  run: () ->
    @init()
    @loadPositions()
