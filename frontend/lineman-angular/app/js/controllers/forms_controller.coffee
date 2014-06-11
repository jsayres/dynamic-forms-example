angular
  .module("admin")
  .controller 'FormsController', ($scope, FormsService) ->

    angular.extend $scope,
      anyForms: false
      forms: []
      projects: {}
      formsLoaded: false
      getForms: ->
        FormsService.getForms().success (data) ->
          $scope.forms = data.forms
          $scope.anyForms = $scope.forms.length > 0
          $scope.formsLoaded = true

    FormsService.getProjects().success (data) ->
      $scope.projects = data.projects
    $scope.getForms()

