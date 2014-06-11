angular
  .module("admin")
  .controller 'FormResponsesController', ($scope, $route, $location, FormsService, MarkdownService) ->

    angular.extend $scope,
      formNumber: parseInt($route.current.params.number)
      formVersion: parseInt($route.current.params.version)
      form: null
      projects: {}
      md2html: MarkdownService.md2html
      nonInfoFields: (fields) -> (f for f in fields when f.kind isnt 'info')
      responses: []
      responsesLoaded: false
      getFormResponses: (formNumber, formVersion) ->
        FormsService.getFormResponses(formNumber, formVersion)
          .success (data) ->
            $scope.form = data.form
            $scope.responses = data.form.responses
            $scope.responsesLoaded = true
          .error ->
            $location.path("/admin/forms")

    FormsService.getProjects().success (data) ->
      $scope.projects = data.projects
    $scope.getFormResponses($scope.formNumber, $scope.formVersion)

