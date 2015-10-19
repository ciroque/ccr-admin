"use strict"
window.Strings = class @Strings
  class @Events
    class @ServiceQueries
      @EnvironmentQuerySuccess    = 'ENVQRYS'
      @EnvironmentQueryFailure    = 'ENVQRYF'
      @ApplicationQuerySuccess    = 'APPQRYS'
      @ApplicationQueryFailure    = 'APPQRYF'
      @ScopeQuerySuccess          = 'SCPQRYS'
      @ScopeQueryFailure          = 'SCPQRYF'
      @SettingQuerySuccess        = 'STGQRYS'
      @SettingQueryFailure        = 'STGQRYF'
      @ConfigurationQuerySuccess  = 'CFGQRYS'
      @ConfigurationQueryFailure  = 'CFGQRYF'

  class @ServiceLocation
    @CcrProtocol = 'http'
    @CcrHost = 'localhost'
    @CcrPort = '80'

  class @ServicePaths
    @RootPath = 'ccr'
    @SettingSegment = 'settings'


