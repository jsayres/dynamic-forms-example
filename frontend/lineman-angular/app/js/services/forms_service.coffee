angular
  .module("admin")
  .factory 'FormsService', ($http, $window, $cacheFactory) ->
    projectsCache = $cacheFactory('projects')
    versionsCache = $cacheFactory('versions', capacity: 1)
    responsesCache = $cacheFactory('responses', capacity: 1)

    clearCaches = ->
      versionsCache.removeAll()
      responsesCache.removeAll()

    http = (method, url, config) ->
      config = angular.extend (config ? {}), method: method, url: url
      $http(config).error(handleError)

    handleError = (data, status, headers, config) ->
      if status is 401
        $window.location.href = '/login'

    getProjects: ->
      http("get", "/api/projects", cache: projectsCache)

    getForms: ->
      http("get", "/api/forms")

    getFormVersions: (number) ->
      http("get", "/api/forms/#{number}/versions", cache: versionsCache)

    getFormVersion: (number, version) ->
      http("get", "/api/forms/#{number}/versions/#{version}")

    getFormResponses: (number, version) ->
      http("get", "/api/forms/#{number}/versions/#{version}/responses", cache: responsesCache)

    save: (form) ->
      (
        if form.number? and form.version?
          http("put", "/api/forms/#{form.number}/versions/#{form.version}", data: {form: form})
        else
          http("post", "/api/forms", data: {form: form})
      ).success (data) -> clearCaches()

    publish: (form) ->
      http("post", "/api/forms/#{form.number}/versions/#{form.version}/publish", data: '')
        .success (data) -> clearCaches()

    unpublish: (form) ->
      http("post", "/api/forms/#{form.number}/versions/#{form.version}/unpublish", data: '')
        .success (data) -> clearCaches()

    newForm: (form = {}) ->
      defaults =
        name: "Form Name"
        project: null
        slug: "form-name"
        fields: []
      overrides =
        number: null
        version: null
        date: null
        published: false
        locked: false
      angular.extend(defaults, form, overrides)

    newVersion: (form) ->
      overrides =
        version: null
        date: null
        published: false
        locked: false
      angular.extend({}, form, overrides)

