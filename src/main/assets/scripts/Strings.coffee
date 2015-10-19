"use strict"
window.Strings = class @Strings
  class @Events
    class @ServiceQueries
      @EnvironmentQuerySuccess  = 'ENVQS'
      @EnvironmentQueryFailure  = 'ENVQF'
      @ApplicationQuerySuccess  = 'APPQS'
      @ApplicationQueryFailure  = 'APPQF'
      @ScopeQuerySuccess        = 'SCPQS'
      @ScopeQueryFailure        = 'SCPQF'
      @SettingQuerySuccess      = 'STGQS'
      @SettingQueryFailure      = 'STGQF'

  class @ServiceLocation
    @CcrProtocol = 'http'
    @CcrHost = 'localhost'
    @CcrPort = '80'

  class @ServicePaths
    @RootPath = 'ccr'
    @SettingSegment = 'setting'


