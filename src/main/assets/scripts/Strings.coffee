"use strict"
window.Strings = class @Strings
  class @Events
    class @ServiceQueries
      @EnvironmentQuerySuccess    = 'ENVQS'
      @EnvironmentQueryFailure    = 'ENVQF'
      @ApplicationQuerySuccess    = 'APPQS'
      @ApplicationQueryFailure    = 'APPQF'
      @ScopeQuerySuccess          = 'SCPQS'
      @ScopeQueryFailure          = 'SCPQF'
      @SettingQuerySuccess        = 'STGQS'
      @SettingQueryFailure        = 'STGQF'
      @ConfigurationQuerySuccess  = 'CFGQS'
      @ConfigurationQueryFailure  = 'CFGQF'

  class @ServiceLocation
    @CcrProtocol = 'http'
    @CcrHost = 'localhost'
    @CcrPort = '80'

  class @ServicePaths
    @RootPath = 'ccr'
    @SettingSegment = 'setting'


