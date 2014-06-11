describe "FormsController", ->

  Given ->
    module('admin')
    inject (@$controller, $rootScope, @FormsService, @$httpBackend) ->
      @projects = p1: 'Project 1', p2: 'Project 2'
      @$httpBackend.whenGET("/api/projects").respond(projects: @projects)
      @$scope = $rootScope.$new()

  afterEach ->
    @$httpBackend.verifyNoOutstandingRequest()
    @$httpBackend.verifyNoOutstandingExpectation()

  describe "when there are no forms", ->
    Given -> @$httpBackend.expectGET('/api/forms').respond(forms: [])
    When -> @$controller('FormsController', {@$scope, @FormsService})

    describe "before init", ->
      Then -> expect(@$scope.formsLoaded).toBeFalsy()
      Then -> expect(@$scope.anyForms).toBeFalsy()
      Then -> expect(@$scope.forms).toEqual([])

    describe "after init", ->
      When -> @$httpBackend.flush()
      Then -> expect(@$scope.formsLoaded).toBeTruthy()
      Then -> expect(@$scope.anyForms).toBeFalsy()
      Then -> expect(@$scope.forms).toEqual([])

  describe "when there is at least one form", ->
    Given -> @$httpBackend.expectGET('/api/forms').respond(forms: [{slug: "form-1"}])
    When -> @$controller('FormsController', {@$scope, @FormsService})

    describe "before init", ->
      Then -> expect(@$scope.formsLoaded).toBeFalsy()
      Then -> expect(@$scope.anyForms).toBeFalsy()
      Then -> expect(@$scope.forms).toEqual([])
      Then -> expect(@$scope.projects).toEqual({})

    describe "after init", ->
      When -> @$httpBackend.flush()
      Then -> expect(@$scope.formsLoaded).toBeTruthy()
      Then -> expect(@$scope.anyForms).toBeTruthy()
      Then -> expect(@$scope.forms.length).toEqual(1)
      Then -> expect(@$scope.forms[0].slug).toEqual('form-1')
      Then -> expect(@$scope.projects).toEqual(@projects)

