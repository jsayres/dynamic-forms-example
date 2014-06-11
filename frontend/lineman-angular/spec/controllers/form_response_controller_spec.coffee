describe "FormResponseController", ->

  Given ->
    module("admin")
    inject (@$controller, $rootScope, @$location, @FormsService, @MarkdownService, @$httpBackend) ->
      @projects = p1: 'Project 1', p2: 'Project 2'
      @$httpBackend.whenGET("/api/projects").respond(projects: @projects)
      @$scope = $rootScope.$new()
      @$route = {current: {params: {number: 1, version: 1, responseNum: 2}}}
      @form =
        number: 1
        version: 1
        fields: [
          {kind: 'info', details: {text: 'Form information.'}},
          {kind: 'short=answer', details: {label: 'Short Answer'}},
          {kind: 'long-answer', details: {label: 'Long Answer'}},
          {
            kind: 'single-choice'
            details:
              question: 'Choose one'
              choices: [{label: 'A'}, {label: 'B'}, {label: 'C'}]
          },
          {
            kind: 'multiple-choice'
            details:
              question: 'Choose some'
              choices: [{label: 'A'}, {label: 'B'}, {label: 'C'}]
          }
        ]
        responses: [
          {
            fieldResponses: [
              {details: answer: 'Short answer response 1'},
              {details: answer: 'Long answer response 1'},
              {details: answer: 'B'},
              {
                details: answers: [
                  {label: 'A', selected: false},
                  {label: 'B', selected: true},
                  {label: 'C', selected: true}
                ]
              }
            ]
          },
          {
            fieldResponses: [
              {details: answer: 'Short answer response 2'},
              {details: answer: 'Long answer response 2'},
              {details: answer: 'C'},
              {
                details: answers: [
                  {label: 'A', selected: true},
                  {label: 'B', selected: false},
                  {label: 'C', selected: true}
                ]
              }
            ]
          }
        ]
      @$controller('FormResponseController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
      
  afterEach ->
    @$httpBackend.verifyNoOutstandingRequest()
    @$httpBackend.verifyNoOutstandingExpectation()

  describe "when there is no form", ->
    When ->
      @$httpBackend.expectGET("/api/forms/1/versions/1/responses").respond(404, '')
      @$controller('FormResponseController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
    When -> @$httpBackend.flush()
    Then -> expect(@$location.path()).toEqual("/admin/forms")

  describe "when there are no responses", ->
    Given -> @form.responses = []
    When ->
      @$httpBackend
        .expectGET("/api/forms/1/versions/1/responses")
        .respond(form: @form)
      @$controller('FormResponseController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
    When -> @$httpBackend.flush()
    Then -> expect(@$location.path()).toEqual("/admin/forms/1/versions/1")

  describe "when there is at least one response", ->
    When ->
      @$httpBackend
        .expectGET("/api/forms/1/versions/1/responses")
        .respond(form: @form)
      @$controller('FormResponseController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})

    describe "before init", ->
      Then -> expect(@$scope.responsesLoaded).toBeFalsy()
      Then -> expect(@$scope.responses).toEqual([])
      Then -> expect(@$scope.form).toBeNull()
      Then -> expect(@$scope.formNumber).toEqual(1)
      Then -> expect(@$scope.formVersion).toEqual(1)
      Then -> expect(@$scope.responseIndex).toEqual(1)
      Then -> expect(@$scope.projects).toEqual({})
      Then -> expect(@$scope.md2html).toEqual(@MarkdownService.md2html)

    describe "after init", ->
      When -> @$httpBackend.flush()
      Then -> expect(@$scope.responsesLoaded).toBeTruthy()
      Then -> expect(@$scope.responses.length).toEqual(2)
      Then -> expect(@$scope.projects).toEqual(@projects)
      Then ->
        for field in @$scope.form.fields
          switch field.kind
            when 'info' then expect(field.response).not.toBeDefined()
            else expect(field.response).toBeDefined()

      describe "#isNextResponse", ->
        describe "when there is a next response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 1}}}
          Then -> expect(@$scope.isNextResponse()).toBeTruthy()

        describe "when there is not a next response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 2}}}
          Then -> expect(@$scope.isNextResponse()).toBeFalsy()

      describe "#isPrevResponse", ->
        describe "when there is a previous response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 2}}}
          Then -> expect(@$scope.isPrevResponse()).toBeTruthy()

        describe "when there is not a previous response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 1}}}
          Then -> expect(@$scope.isPrevResponse()).toBeFalsy()

      describe "#nextResponse", ->
        describe "when there is a next response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 1}}}
          Then -> expect(@$scope.nextResponse()).toEqual(2)

        describe "when there is not a next response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 2}}}
          Then -> expect(@$scope.nextResponse()).toEqual(2)

      describe "#prevResponse", ->
        describe "when there is a previous response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 2}}}
          Then -> expect(@$scope.prevResponse()).toEqual(1)

        describe "when there is not a previous response", ->
          Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 1}}}
          Then -> expect(@$scope.prevResponse()).toEqual(1)

    describe "when requesting a responseNum too high", ->
      Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 4}}}
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms/1/versions/1/responses/2")

    describe "when requesting a responseNum too low", ->
      Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 0}}}
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms/1/versions/1/responses/1")

    describe "when requesting a bad responseNum", ->
      Given -> @$route = {current: {params: {number: 1, version: 1, responseNum: 'wtf'}}}
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms/1/versions/1/responses/1")

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

