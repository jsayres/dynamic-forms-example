angular
  .module("admin")
  .controller 'FormVersionsController', ($scope, $route, $location, FormsService) ->

    angular.extend $scope,
      number: parseInt($route.current.params.number)
      versions: []
      currentVersion: null
      projects: {}
      versionsLoaded: false
      getFormVersions: (number) ->
        FormsService.getFormVersions(number)
          .success (data) ->
            $scope.versions = data.forms
            $scope.versions.sort (a, b) -> b.version - a.version
            $scope.currentVersion = (v for v in $scope.versions when v.current)[0]
            $scope.versionsLoaded = true
          .error ->
            $location.path("/admin/forms")

    FormsService.getProjects().success (data) ->
      $scope.projects = data.projects
    $scope.getFormVersions($scope.number)

