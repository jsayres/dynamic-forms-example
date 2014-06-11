angular
  .module("admin")
  .controller 'FormResponseController', ($scope, $route, $location, FormsService, MarkdownService) ->

    angular.extend $scope,
      formNumber: parseInt($route.current.params.number)
      formVersion: parseInt($route.current.params.version)
      responseIndex: parseInt($route.current.params.responseNum) - 1
      form: null
      projects: {}
      md2html: MarkdownService.md2html
      nonInfoFields: (fields) -> (f for f in fields when f.kind isnt 'info')
      responses: []
      responsesLoaded: false
      isNextResponse: -> $scope.responseIndex < $scope.responses.length - 1
      isPrevResponse: -> $scope.responseIndex > 0
      nextResponse: -> $scope.responseIndex + if $scope.isNextResponse() then 2 else 1
      prevResponse: -> $scope.responseIndex + if $scope.isPrevResponse() then 0 else 1
      getFormResponses: (formNumber, formVersion) ->
        FormsService.getFormResponses(formNumber, formVersion)
          .success(setResponseData)
          .error -> $location.path("/admin/forms")

    setResponseData = (data) ->
      $scope.form = data.form
      $scope.responses = data.form.responses
      $scope.responsesLoaded = true
      if $scope.responses.length is 0
        $location.path("/admin/forms/#{$scope.formNumber}/versions/#{$scope.formVersion}")
      else if $scope.responseIndex >= $scope.responses.length
        viewResponse($scope.responses.length - 1)
      else if $scope.responseIndex < 0 or isNaN($scope.responseIndex)
        viewResponse(0)
      else
        attachResponsesToFields()

    attachResponsesToFields = ->
      fieldResponses = $scope.responses[$scope.responseIndex].fieldResponses
      for field, i in $scope.nonInfoFields($scope.form.fields)
        field.response = fieldResponses[i].details

    viewResponse = (index) ->
      n = index + 1
      url = "/admin/forms/#{$scope.formNumber}/versions/#{$scope.formVersion}/responses/#{n}"
      $location.path(url)

    FormsService.getProjects().success (data) ->
      $scope.projects = data.projects
    $scope.getFormResponses($scope.formNumber, $scope.formVersion)
