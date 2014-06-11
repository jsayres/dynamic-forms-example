describe "FormResponsesController", ->

  Given ->
    module("admin")
    inject (@$controller, $rootScope, @$location, @FormsService, @MarkdownService, @$httpBackend) ->
      @projects = p1: 'Project 1', p2: 'Project 2'
      @$httpBackend.whenGET("/api/projects").respond(projects: @projects)
      @$scope = $rootScope.$new()
      @$route = {current: {params: {number: 1, version: 1}}}
      @form =
        number: 1
        version: 1
        fields: [{kind: 'short=answer', details: {label: 'Answer'}}]
        responses: [
          formNumber: 1
          formVersion: 1
          fieldResponses: [{answer: 'Something'}]
        ]

  afterEach ->
    @$httpBackend.verifyNoOutstandingRequest()
    @$httpBackend.verifyNoOutstandingExpectation()

  describe "when there is no form", ->
    Given ->
      @$httpBackend.expectGET("/api/forms/1/versions/1/responses").respond(404, '')
      @$controller('FormResponsesController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
    When -> @$httpBackend.flush()
    Then -> expect(@$location.path()).toEqual("/admin/forms")

  describe "when there are no responses", ->
    Given -> @form.responses = []
    Given ->
      @$httpBackend
        .expectGET("/api/forms/1/versions/1/responses")
        .respond(form: @form)
      @$controller('FormResponsesController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
    When -> @$httpBackend.flush()
    Then -> expect(@$location.path()).not.toEqual("/admin/forms")
    Then -> expect(@$scope.responses).toEqual([])

  describe "when there is at least one response", ->
    Given ->
      @$httpBackend
        .expectGET("/api/forms/1/versions/1/responses")
        .respond(form: @form)
      @$controller('FormResponsesController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})

    describe "before init", ->
      Then -> expect(@$scope.responsesLoaded).toBeFalsy()
      Then -> expect(@$scope.responses).toEqual([])
      Then -> expect(@$scope.form).toBeNull()
      Then -> expect(@$scope.formNumber).toEqual(1)
      Then -> expect(@$scope.formVersion).toEqual(1)
      Then -> expect(@$scope.projects).toEqual({})

    describe "after init", ->
      When -> @$httpBackend.flush()
      Then -> expect(@$scope.responsesLoaded).toBeTruthy()
      Then -> expect(@$scope.responses.length).toEqual(1)
      Then -> expect(@$scope.responses[0].formNumber).toEqual(1)
      Then -> expect(@$scope.projects).toEqual(@projects)
      Then -> expect(@$scope.md2html).toEqual(@MarkdownService.md2html)

    describe "#nonInfoFields", ->
      Given -> @fields = [
        {kind: 'short-answer'},
        {kind: 'multiple-choice'},
        {kind: 'info'},
        {kind: 'long-answer'},
        {kind: 'single-choice'}
      ]
      Then -> expect(@$scope.nonInfoFields(@fields)).toEqual [
        {kind: 'short-answer'},
        {kind: 'multiple-choice'},
        {kind: 'long-answer'},
        {kind: 'single-choice'}
      ]

