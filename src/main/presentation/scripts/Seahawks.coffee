"use strict"

window.Seahawks = class Seahawks
  ENVIRONMENT = 'NFL'
  APPLICATION = 'Seahawks'
  SCOPE = 'Offense'
  OFFENSIVE_POSITIONS = [
    'positionQuarterback',
    'positionCenter',
    'positionRightGuard',
    'positionLeftGuard',
    'positionRightTackle',
    'positionLeftTackle',
    'positionWideReceiver1',
    'positionWideReceiver2',
    'positionTightEnd1',
    'positionRunningBack',
    'positionHalfBack'
  ]

  @OFFENSIVE_POSITIONS = OFFENSIVE_POSITIONS
  @ENVIRONMENT = ENVIRONMENT
  @APPLICATION = APPLICATION
  @SCOPE = SCOPE

  constructor: () ->
    @POSITIONS = OFFENSIVE_POSITIONS

  generateConfigurations: () ->
    TODAY = new Date()

    ONE_MINUTE_FROM_NOW = new Date(TODAY).setMinutes(TODAY.getMinutes() + 1)
    TWO_MINUTES_FROM_NOW = new Date(TODAY).setMinutes(TODAY.getMinutes() + 2)
    TOMORROW = new Date(TODAY).setDate(TODAY.getDate() + 1)

    toIsoDateString = (date) ->
      new Date(date).toISOString()

    uuid = ->
      'xxxxxxxx-xxxx-axxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = if c is 'x' then r else (r & 0x3 | 0x8)
        v.toString(16)
      )

    oneMinuteTemporalization = {
      effectiveAt: toIsoDateString(TODAY),
      expiresAt: toIsoDateString(ONE_MINUTE_FROM_NOW),
      ttl: 1
    }
    inOneMinuteTemporalization = {
      effectiveAt: toIsoDateString(ONE_MINUTE_FROM_NOW),
      expiresAt: toIsoDateString(TOMORROW),
      ttl: 2
    }

    twoMinuteTemporalization = {
      effectiveAt: toIsoDateString(TODAY),
      expiresAt: toIsoDateString(TWO_MINUTES_FROM_NOW),
      ttl: 3
    }
    inTwoMinutesTemporalization = {
      effectiveAt: toIsoDateString(TWO_MINUTES_FROM_NOW),
      expiresAt: toIsoDateString(TOMORROW),
      ttl: 4
    }

    oneDayTemporalization = {effectiveAt: toIsoDateString(TODAY), expiresAt: toIsoDateString(TOMORROW), ttl: 5}

    players = [
      {position: @POSITIONS[0], name: 'Russell Wilson', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[1], name: 'Drew Nowak', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[2], name: 'J. R. Sweezy', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[3], name: 'Justin Britt', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[4], name: 'Gary Gilliam', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[5], name: 'Russell Okung', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[6], name: 'Doug Baldwin', temporalization: oneMinuteTemporalization, willSub: "true" },
      {position: @POSITIONS[7], name: 'Jermaine Kearse', temporalization: twoMinuteTemporalization, willSub: "true" },
      {position: @POSITIONS[8], name: 'Jimmy Graham', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[9], name: 'Marshawn Lynch', temporalization: twoMinuteTemporalization, willSub: "true" },
      {position: @POSITIONS[10], name: 'Will Tukuafu', temporalization: oneDayTemporalization, willSub: "false" },
      {position: @POSITIONS[6], name: 'Tyler Lockett', temporalization: inOneMinuteTemporalization, willSub: "false" },
      {position: @POSITIONS[7], name: 'Ricardo Lockette', temporalization: inTwoMinutesTemporalization, willSub: "false" },
      {position: @POSITIONS[9], name: 'Fred Jackson', temporalization: inTwoMinutesTemporalization, willSub: "false" }
    ]
    {
      _id: uuid(),
      key: {
        environment: ENVIRONMENT,
        application: APPLICATION,
        scope: SCOPE,
        setting: player.position,
        sourceId: player.willSub
      },
      value: player.name,
      temporality: player.temporalization
    } for player in players