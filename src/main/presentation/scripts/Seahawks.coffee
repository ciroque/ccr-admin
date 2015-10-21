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

    TWO_MINUTES_FROM_NOW = new Date(TODAY).setMinutes(TODAY.getMinutes() + 2)
    THREE_MINUTES_FROM_NOW = new Date(TODAY).setMinutes(TODAY.getMinutes() + 3)
    TOMORROW = new Date(TODAY).setDate(TODAY.getDate() + 1)

    toIsoDateString = (date) ->
      new Date(date).toISOString()

    uuid = ->
      'xxxxxxxx-xxxx-axxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = if c is 'x' then r else (r & 0x3 | 0x8)
        v.toString(16)
      )

    twoMinuteTemporalization = {
      effectiveAt: toIsoDateString(TODAY),
      expiresAt: toIsoDateString(TWO_MINUTES_FROM_NOW),
      ttl: 10
    }
    inTwoMinutesTemporalization = {
      effectiveAt: toIsoDateString(TWO_MINUTES_FROM_NOW),
      expiresAt: toIsoDateString(TOMORROW),
      ttl: 2
    }

    threeMinuteTemporalization = {
      effectiveAt: toIsoDateString(TODAY),
      expiresAt: toIsoDateString(THREE_MINUTES_FROM_NOW),
      ttl: 5
    }
    inThreeMinutesTemporalization = {
      effectiveAt: toIsoDateString(THREE_MINUTES_FROM_NOW),
      expiresAt: toIsoDateString(TOMORROW),
      ttl: 2
    }

    oneDayTemporalization = {effectiveAt: toIsoDateString(TODAY), expiresAt: toIsoDateString(TOMORROW), ttl: 20}

    players = [
      {position: @POSITIONS[0], name: 'Russell Wilson', temporalization: oneDayTemporalization},
      {position: @POSITIONS[1], name: 'Drew Nowak', temporalization: oneDayTemporalization},
      {position: @POSITIONS[2], name: 'J. R. Sweezy', temporalization: oneDayTemporalization},
      {position: @POSITIONS[3], name: 'Justin Britt', temporalization: oneDayTemporalization},
      {position: @POSITIONS[4], name: 'Gary Gilliam', temporalization: oneDayTemporalization},
      {position: @POSITIONS[5], name: 'Russell Okung', temporalization: oneDayTemporalization},
      {position: @POSITIONS[6], name: 'Doug Baldwin', temporalization: twoMinuteTemporalization},
      {position: @POSITIONS[7], name: 'Jermaine Kearse', temporalization: threeMinuteTemporalization},
      {position: @POSITIONS[8], name: 'Jimmy Graham', temporalization: oneDayTemporalization},
      {position: @POSITIONS[9], name: 'Marshawn Lynch', temporalization: threeMinuteTemporalization},
      {position: @POSITIONS[10], name: 'Will Tukuafu', temporalization: oneDayTemporalization},
      {position: @POSITIONS[6], name: 'Tyler Lockett', temporalization: inTwoMinutesTemporalization},
      {position: @POSITIONS[7], name: 'Ricardo Lockette', temporalization: inThreeMinutesTemporalization},
      {position: @POSITIONS[9], name: 'Fred Jackson', temporalization: inThreeMinutesTemporalization}
    ]
    {
      _id: uuid(),
      key: {
        environment: ENVIRONMENT,
        application: APPLICATION,
        scope: SCOPE,
        setting: player.position
      },
      value: player.name,
      temporality: player.temporalization
    } for player in players