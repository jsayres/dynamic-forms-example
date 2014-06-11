describe "FormVersionController", ->

  Given ->
    module("admin")
    inject (@$controller, $rootScope, @$location, @FormsService, @MarkdownService, @$httpBackend) ->
      @projects = p1: 'Project 1', p2: 'Project 2'
      @$httpBackend.whenGET("/api/projects").respond(projects: @projects)
      @$scope = $rootScope.$new()
      @$route = {current: {params: {number: 1, version: 1}}}
      @versions = [
        {number: 1, version: 1, slug: 'form-1a'},
        {number: 1, version: 2, slug: 'form-1b', current: true}
      ]
  When ->
      @$controller('FormVersionController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
      
  afterEach ->
    @$httpBackend.verifyNoOutstandingRequest()
    @$httpBackend.verifyNoOutstandingExpectation()

  describe "when form doesn't exist", ->
    Given -> @$httpBackend.expectGET("/api/forms/1/versions").respond(404, '')
    When -> @$httpBackend.flush()
    Then -> expect(@$location.path()).toEqual("/admin/forms")

  describe "when form exists", ->
    Given ->
      @$httpBackend
        .expectGET("/api/forms/1/versions")
        .respond(forms: @versions)

    describe "for bad version number", ->
      When -> @$httpBackend.flush()

      describe "when too high", ->
        Given -> @$route.current.params.version = 3
        Then -> expect(@$location.path()).toEqual("/admin/forms")

      describe "when too low", ->
        Given -> @$route.current.params.version = 0
        Then -> expect(@$location.path()).toEqual("/admin/forms")

      describe "when invalid", ->
        Given -> @$route.current.params.version = 'wtf'
        Then -> expect(@$location.path()).toEqual("/admin/forms")

    describe "before init", ->
      Then -> expect(@$scope.versionsLoaded).toBeFalsy()
      Then -> expect(@$scope.form).toBeFalsy()
      Then -> expect(@$scope.number).toEqual(1)
      Then -> expect(@$scope.version).toEqual(1)
      Then -> expect(@$scope.versions).toEqual([])
      Then -> expect(@$scope.projects).toEqual({})
      Then -> expect(@$scope.protocol()).toEqual(@$location.protocol())
      Then -> expect(@$scope.host()).toEqual(@$location.host())
      Then -> expect(@$scope.port()).toEqual(@$location.port())
      Then -> expect(@$scope.md2html).toEqual(@MarkdownService.md2html)

    describe "after init", ->
      When -> @$httpBackend.flush()
      Then -> expect(@$scope.versionsLoaded).toBeTruthy()
      Then -> expect(@$scope.form.number).toEqual(1)
      Then -> expect(@$scope.form.version).toEqual(1)
      Then -> expect(@$scope.form.slug).toEqual('form-1a')
      Then -> expect(@$scope.versions.length).toEqual(2)
      Then -> expect(@$scope.projects).toEqual(@projects)

      describe "#isNextVersion", ->
        describe "when there is a next version", ->
          Given -> @$route.current.params.version = 1
          Then -> expect(@$scope.isNextVersion()).toBeTruthy()

        describe "when there is not a next version", ->
          Given -> @$route.current.params.version = 2
          Then -> expect(@$scope.isNextVersion()).toBeFalsy()

      describe "#isPrevVersion", ->
        describe "when there is a previous version", ->
          Given -> @$route.current.params.version = 2
          Then -> expect(@$scope.isPrevVersion()).toBeTruthy()

        describe "when there is not a previous version", ->
          Given -> @$route.current.params.version = 1
          Then -> expect(@$scope.isPrevVersion()).toBeFalsy()

      describe "#nextVersion", ->
        describe "when there is a next version", ->
          Given -> @$route.current.params.version = 1
          Then -> expect(@$scope.nextVersion()).toEqual(2)

        describe "when there is not a next version", ->
          Given -> @$route.current.params.version = 2
          Then -> expect(@$scope.nextVersion()).toEqual(2)

      describe "#prevVersion", ->
        describe "when there is a previous version", ->
          Given -> @$route.current.params.version = 2
          Then -> expect(@$scope.prevVersion()).toEqual(1)

        describe "when there is a not previous version", ->
          Given -> @$route.current.params.version = 1
          Then -> expect(@$scope.prevVersion()).toEqual(1)

    describe "#publish", ->
      When -> @$httpBackend.flush()

      describe "for an unpublished form", ->
        When -> @$scope.form.published = false
        When ->
          @$httpBackend
            .expectPOST("/api/forms/1/versions/1/publish")
            .respond(slug: 'new-slug', published: true)
        When -> @$scope.publish()
        When -> @$httpBackend.flush()
        Then -> expect(@$scope.form.published).toBeTruthy()
        Then -> expect(@$scope.form.locked).toBeTruthy()
        Then -> expect(@$scope.form.slug).toEqual('new-slug')

      describe "for a published form", ->
        When -> @$scope.form.published = true
        When -> @$scope.publish()
        When -> expect(@$httpBackend.flush).toThrow()
        Then -> expect(@$scope.form.published).toBeTruthy()

    describe "#unpublish", ->
      When -> @$httpBackend.flush()

      describe "for a published form", ->
        When -> @$scope.form.published = true
        When ->
          @$httpBackend
            .expectPOST("/api/forms/1/versions/1/unpublish")
            .respond(published: false)
        When -> @$scope.unpublish()
        When -> @$httpBackend.flush()
        Then -> expect(@$scope.form.published).toBeFalsy()

      describe "for an unpublished form", ->
        When -> @$scope.form.published = false
        When -> @$scope.unpublish()
        When -> expect(@$httpBackend.flush).toThrow()
        Then -> expect(@$scope.form.published).toBeFalsy()

