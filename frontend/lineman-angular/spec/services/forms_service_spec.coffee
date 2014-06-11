describe "FormsService", ->

  Given ->
    mocks =
      mockCache:
        get: ->
        put: ->
        removeAll: ->
      mockCacheFactory: -> mocks.mockCache
    @cacheGet = spyOn(mocks.mockCache, 'get')
    @cachePut = spyOn(mocks.mockCache, 'put')
    @cacheRemoveAll = spyOn(mocks.mockCache, 'removeAll')

    module "admin", ($provide) ->
      $provide.value('$cacheFactory', mocks.mockCacheFactory)
      $provide.value('$window', {location: href: ''})
      null

    inject (@$httpBackend, @$window, @FormsService) ->
      @projects = p1: 'Project 1', p2: 'Project 2'

  describe "when user is logged out", ->
    Given -> @$httpBackend.expectGET('/api/forms').respond(401)
    When -> @FormsService.getForms()
    When -> @$httpBackend.flush()
    Then -> expect(@$window.location.href).toEqual('/login')

  describe "#getForms", ->
    Given -> @$httpBackend.expectGET('/api/forms').respond('')
    When -> @FormsService.getForms()
    Then -> @$httpBackend.flush()

  describe "#getFormVersions", ->
    Given -> @form_number = 1
    Given -> @url = "/api/forms/#{@form_number}/versions"
    Given -> @$httpBackend.expectGET(@url).respond('')
    When -> @FormsService.getFormVersions(@form_number)
    Then -> @$httpBackend.flush()

  describe "#save", ->
    describe "new form", ->
      Given -> @form = number: null, version: null
      Given -> @$httpBackend.expectPOST('/api/forms', form: @form).respond(number: 1, version: 1)
      When -> @FormsService.save(@form)
      When -> @$httpBackend.flush()
      Then -> expect(@cacheRemoveAll).toHaveBeenCalled()

    describe "existing form", ->
      Given -> @form = number: 1, version: 1
      Given -> @url = "/api/forms/#{@form.number}/versions/#{@form.version}"
      Given -> @$httpBackend.expectPUT(@url, form: @form).respond(date: new Date())
      When -> @FormsService.save(@form)
      When -> @$httpBackend.flush()
      Then -> expect(@cacheRemoveAll).toHaveBeenCalled()

  describe "#publish", ->
    Given -> @form = number: 1, version: 1, published: false
    Given -> @url = "/api/forms/#{@form.number}/versions/#{@form.version}/publish"
    Given -> @$httpBackend.expectPOST(@url).respond(published: true)
    When -> @FormsService.publish(@form)
    When -> @$httpBackend.flush()
    Then -> expect(@cacheRemoveAll).toHaveBeenCalled()

  describe "#unpublish", ->
    Given -> @form = number: 1, version: 1, published: true
    Given -> @url = "/api/forms/#{@form.number}/versions/#{@form.version}/unpublish"
    Given -> @$httpBackend.expectPOST(@url).respond(published: false)
    When -> @FormsService.unpublish(@form)
    When -> @$httpBackend.flush()
    Then -> expect(@cacheRemoveAll).toHaveBeenCalled()

  describe "#newForm", ->
    When -> @newForm = @FormsService.newForm()
    Then -> expect(@newForm.number).toBeNull()
    Then -> expect(@newForm.version).toBeNull()
    Then -> expect(@newForm.date).toBeNull()
    Then -> expect(@newForm.published).toEqual(false)
    Then -> expect(@newForm.locked).toEqual(false)
    Then -> expect(@newForm.fields).toEqual([])
    Then -> expect(@newForm.name).toBeDefined()
    Then -> expect(@newForm.project).toBeDefined()
    Then -> expect(@newForm.slug).toBeDefined()

    describe "with form as arugment", ->
      Given -> @form = number: 1, version: 1, name: "Form 1", published: true, locked: true
      When -> @newForm = @FormsService.newForm(@form)
      Then -> expect(@newForm.number).toBeNull()
      Then -> expect(@newForm.version).toBeNull()
      Then -> expect(@newForm.date).toBeNull()
      Then -> expect(@newForm.published).toEqual(false)
      Then -> expect(@newForm.locked).toEqual(false)
      Then -> expect(@newForm.name).toEqual(@form.name)

  describe "#newVersion", ->
    Given -> @form = number: 1, version: 1, name: "Form 1", published: true, locked: true
    When -> @newForm = @FormsService.newVersion(@form)
    Then -> expect(@newForm.number).toEqual(1)
    Then -> expect(@newForm.version).toBeNull()
    Then -> expect(@newForm.date).toBeNull()
    Then -> expect(@newForm.published).toEqual(false)
    Then -> expect(@newForm.locked).toEqual(false)
    Then -> expect(@newForm.name).toEqual(@form.name)

  describe "#getFormResponses", ->
    Given -> @form = number: 1, version: 1, name: "Form 1"
    Given -> @url = "/api/forms/#{@form.number}/versions/#{@form.version}/responses"
    Given -> @$httpBackend.expectGET(@url).respond('')
    When -> @FormsService.getFormResponses(@form.number, @form.version)
    Then -> @$httpBackend.flush()

  describe "#getProjects", ->
    Given -> @$httpBackend.expectGET("/api/projects").respond(projects: @projects)
    When -> @FormsService.getProjects()
    Then -> @$httpBackend.flush()
