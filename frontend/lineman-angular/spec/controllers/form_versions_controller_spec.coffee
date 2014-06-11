describe "FormVersionsController", ->

  Given ->
    module("admin")
    inject (@$controller, $rootScope, @$location, @FormsService, @$httpBackend) ->
      @projects = p1: 'Project 1', p2: 'Project 2'
      @$httpBackend.whenGET("/api/projects").respond(projects: @projects)
      @$scope = $rootScope.$new()
      @$route = {current: {params: {number: 1}}}

  afterEach ->
    @$httpBackend.verifyNoOutstandingRequest()
    @$httpBackend.verifyNoOutstandingExpectation()

  describe "when there are no versions", ->
    Given ->
      @$httpBackend.expectGET("/api/forms/1/versions").respond(404, '')
      @$controller('FormVersionsController', {@$scope, @$route, @$location, @FormsService})
    When -> @$httpBackend.flush()
    Then -> expect(@$location.path()).toEqual("/admin/forms")

  describe "when there is at least one version", ->
    Given ->
      forms = [{slug: "form-1"}, {slug: "form-1a", current: true}]
      @$httpBackend
        .expectGET("/api/forms/1/versions")
        .respond {forms: forms}
      @$controller('FormVersionsController', {@$scope, @$route, @$location, @FormsService})

    describe "before init", ->
      Then -> expect(@$scope.versionsLoaded).toBeFalsy()
      Then -> expect(@$scope.versions).toEqual([])
      Then -> expect(@$scope.currentVersion).toBeFalsy()
      Then -> expect(@$scope.projects).toEqual({})

    describe "after init", ->
      When -> @$httpBackend.flush()
      Then -> expect(@$scope.versionsLoaded).toBeTruthy()
      Then -> expect(@$scope.versions.length).toEqual(2)
      Then -> expect(@$scope.versions[1].slug).toEqual('form-1a')
      Then -> expect(@$scope.currentVersion.slug).toEqual('form-1a')
      Then -> expect(@$scope.projects).toEqual(@projects)


