"use strict"

window.ConfigurationGenerator = class ConfigurationGenerator

  ENVIRONMENTS = ['prod', 'qa', 'devint', 'dev', 'integration']
  APPLICATIONS = ['ccr', 'CCRAdmin', 'SampleApp', 'Avenger', 'BillabilityService', 'BillabilityAnnotator']
  SCOPES = ['service', 'logging', 'appearance']
  SETTINGS = ['host', 'port', 'protocol', 'loglevel', 'logfilename', 'theme', 'V2-UI']

  APP_SCOPE_MAP = {
    ccr: [SCOPES[0], SCOPES[1]],
    CCRAdmin: [SCOPES[0], SCOPES[1], SCOPES[2]],
    SampleApp: [SCOPES[1]],
    Avenger: [SCOPES[1]],
    BillabilityService: [SCOPES[1]],
    BillabilityAnnotator: [SCOPES[1]]
  }

  SCOPE_SETTING_MAP = {
    service: [SETTINGS[0], SETTINGS[1], SETTINGS[2]],
    logging: [SETTINGS[3], SETTINGS[4]],
    appearance: [SETTINGS[5], SETTINGS[6]]
  }

  TODAY = new Date()
  YESTERDAY = new Date().setDate(TODAY.getDate() - 1)
  TOMORROW = new Date().setDate(TODAY.getDate() + 1)
  DAY_AFTER_TOMORROW = new Date(TOMORROW).setDate(TODAY.getDate() + 2)
  LAST_YEAR_YESTERDAY = new Date(YESTERDAY).setYear(TODAY.getFullYear() - 1)
  TODAY_NEXT_YEAR = new Date(TODAY).setYear(TODAY.getFullYear() + 1)

  getDates: () ->
    yesterday = new Date(YESTERDAY).toISOString()
    lastYearYesterday = new Date(LAST_YEAR_YESTERDAY).toISOString()
    tomorrow = new Date(TOMORROW).toISOString()
    dayAfterTomorrow = new Date(DAY_AFTER_TOMORROW).toISOString()
    todayNextYear = new Date(TODAY_NEXT_YEAR).toISOString()
    [
      {effectiveAt: lastYearYesterday, expiresAt: yesterday, ttl: 1440},
      {effectiveAt: yesterday, expiresAt: tomorrow, ttl: 5},
      {effectiveAt: dayAfterTomorrow, expiresAt: todayNextYear, ttl: 3600}
    ]

  uuid = ->
    'xxxxxxxx-xxxx-axxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else (r & 0x3 | 0x8)
      v.toString(16)
    )

  uniqueString = (length = 8) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length

  combine: (env) ->
    @combine2(env, app) for app in APPLICATIONS

  combine2: (env, app) ->
    @combine3(env, app, scp) for scp in APP_SCOPE_MAP[app]

  combine3: (env, app, scp) ->
    @combine4(env, app, scp, stg) for stg in SCOPE_SETTING_MAP[scp]

  combine4: (env, app, scp, stg) ->
    {
    _id: uuid(),
    key: {
      environment: env,
      application: app,
      scope: scp,
      setting: stg
    },
    value: uniqueString(),
    temporality
    } for temporality in @getDates()

  generate: () ->
    @combine(env) for env in ENVIRONMENTS

  flattened: (nested) ->
    flattened = []
    i1 = 0
    while i1 < nested.length
      l2 = nested[i1]
      i2 = 0
      while i2 < l2.length
        l3 = l2[i2]
        i3 = 0
        while i3 < l3.length
          l4 = l3[i3]
          i4 = 0
          while i4 < l4.length
            l5 = l4[i4]
            i5 = 0
            while i5 < l5.length
              flattened.push l5[i5]
              i5++
            i4++
          i3++
        i2++
      i1++
    flattened

  postToService: (configurations, callback = null) ->
    jQuery.ajax({
      type: 'POST',
      url: 'http://localhost:35487/ccr/schedule/',
      data: JSON.stringify(configuration),
      dataType: 'json',
      contentType: 'application/json',
      'success': (d,r,x) -> callback({result: r, data: JSON.stringify(d)}) if callback
    }) for configuration in configurations
