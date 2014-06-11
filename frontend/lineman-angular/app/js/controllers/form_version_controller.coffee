angular
  .module("admin")
  .controller 'FormVersionController', ($scope, $route, $location, FormsService, MarkdownService) ->

    angular.extend $scope,
      number: parseInt($route.current.params.number)
      version: parseInt($route.current.params.version)
      form: null
      projects: {}
      md2html: MarkdownService.md2html
      versions: []
      versionsLoaded: false
      protocol: -> $location.protocol()
      host: -> $location.host()
      port: -> $location.port()
      isNextVersion: -> $scope.version < $scope.versions.length
      isPrevVersion: -> $scope.version > 1
      nextVersion: -> $scope.version + if $scope.isNextVersion() then 1 else 0
      prevVersion: -> $scope.version - if $scope.isPrevVersion() then 1 else 0
      getFormVersions: (number) ->
        FormsService.getFormVersions(number)
          .success(setResponseData)
          .error -> $location.path("/admin/forms")
      publish: ->
        FormsService.publish($scope.form).success (data) ->
          $scope.form.slug = data.slug
          $scope.form.published = true
          $scope.form.locked = true
      unpublish: ->
        FormsService.unpublish($scope.form).success ->
          $scope.form.published = false

    setResponseData = (data) ->
      $scope.versions = data.forms
      if 0 < $scope.version <= $scope.versions.length
        $scope.form = $scope.versions[$scope.version - 1]
        $scope.versionsLoaded = true
      else
        $location.path("/admin/forms")

    FormsService.getProjects().success (data) ->
      $scope.projects = data.projects
    $scope.getFormVersions($scope.number, $scope.version)

