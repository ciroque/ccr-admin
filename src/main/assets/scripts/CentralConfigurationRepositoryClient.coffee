class CentralConfigurationRepositoryClient
  constructor: () ->
    @cache = new ExpiringCache()

  retrieveEnvironments: -> []
  retrieveApplications: (environment) -> []
  retrieveScopes: (environment, application) -> []
  retrieveSettings: (environment, application, scope) -> []
  retrieveConfiguration: (environment, application, scope, setting, sourceId = null) ->
    # check cache

    []
