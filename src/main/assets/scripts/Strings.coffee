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

    class @UiEvents
      @EnvironmentSelected        = 'UIENVSEL'
      @ApplicationSelected        = 'UIAPPSEL'
      @ScopeSelected              = 'UISCPSEL'
      @SettingSelected            = 'UISTGSEL'
      @ClearEnvironments          = 'UICLRENV'
      @ClearApplications          = 'UICLRAPP'
      @ClearScopes                = 'UICLRSCP'
      @ClearSettings              = 'UICLRSTG'
      @ClearConfiguration         = 'UICLRCFG'

    class @ServiceCallTriggers
      @InitiateEnvironmentQuery   = 'ENVQRYI'
      @InitiateApplicationQuery   = 'APPQRYI'
      @InitiateScopeQuery         = 'SCPQRYI'
      @InitiateSettingQuery       = 'STGQRYI'
      @InitiateConfigurationQuery = 'CFGQRYI'

  class @ServiceLocation
    @CcrProtocol = 'http'
    @CcrHost = '54.187.190.215'
    @CcrPort = '8378'

  class @ServicePaths
    @RootPath = 'ccr'
    @SettingSegment = 'configurations'


