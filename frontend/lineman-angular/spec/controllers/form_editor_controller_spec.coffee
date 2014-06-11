describe "FormEditorController", ->

  Given ->
    module("admin")
    inject (@$controller, $rootScope, @$location, @FormsService, @MarkdownService, @$httpBackend) ->
      @projects = p1: 'Project 1', p2: 'Project 2'
      @$httpBackend.whenGET("/api/projects").respond(projects: @projects)
      @$scope = $rootScope.$new()

  afterEach ->
    @$httpBackend.verifyNoOutstandingRequest()
    @$httpBackend.verifyNoOutstandingExpectation()

  describe "for a new form", ->
    Given ->
      @$location.path("/admin/forms/new")
      @$route = {current: {params: {}}}
      @$controller('FormEditorController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
    Then -> expect(@$scope.newForm).toBeTruthy()
    Then -> expect(@$scope.form.number).toBeNull()
    Then -> expect(@$scope.form.version).toBeNull()
    Then -> expect(@$scope.dirty).toBeFalsy()

    describe "#save", ->
      When ->
        @$httpBackend
          .expectPOST("/api/forms", form: @$scope.form)
          .respond(201, number: 2, version: 2)
      When -> @$scope.save()
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms/2/versions/2/edit")

  describe "for a new form from a copy", ->
    Given ->
      @form = number: 1, version: 1, name: "Test Form"
      @$location.path("/admin/forms/1/versions/1/new-form")
      @$route = {current: {params: {number: 1, version: 1}}}
      @$httpBackend.expectGET("/api/forms/1/versions/1").respond(form: @form)
      @$controller('FormEditorController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
    When -> @$httpBackend.flush()
    Then -> expect(@$scope.newFormFromCopy).toBeTruthy()
    Then -> expect(@$scope.form.number).toBeNull()
    Then -> expect(@$scope.form.version).toBeNull()
    Then -> expect(@$scope.form.name).toEqual("Test Form")
    Then -> expect(@$scope.dirty).toBeTruthy()
    Then -> expect(@$scope.protocol()).toEqual(@$location.protocol())
    Then -> expect(@$scope.host()).toEqual(@$location.host())
    Then -> expect(@$scope.port()).toEqual(@$location.port())

    describe "#save", ->
      When ->
        @$httpBackend
          .expectPOST("/api/forms", form: @$scope.form)
          .respond(201, number: 2, version: 1)
      When -> @$scope.save()
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms/2/versions/1/edit")

  describe "for a new version from a copy", ->
    Given ->
      @form = number: 1, version: 1, name: "Test Form"
      @$location.path("/admin/forms/1/versions/1/new-version")
      @$route = {current: {params: {number: 1, version: 1}}}
      @$httpBackend.expectGET("/api/forms/1/versions/1").respond(form: @form)
      @$controller('FormEditorController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
    When -> @$httpBackend.flush()
    Then -> expect(@$scope.newFormFromCopy).toBeFalsy()
    Then -> expect(@$scope.newVersionFromCopy).toBeTruthy()
    Then -> expect(@$scope.form.number).toEqual(1)
    Then -> expect(@$scope.form.version).toBeNull()
    Then -> expect(@$scope.form.name).toEqual("Test Form")
    Then -> expect(@$scope.dirty).toBeTruthy()

    describe "#save", ->
      When ->
        @$httpBackend
          .expectPOST("/api/forms", form: @$scope.form)
          .respond(201, number: 1, version: 2)
      When -> @$scope.save()
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms/1/versions/2/edit")

  describe "for an existing form", ->
    Given ->
      @$route = {current: {params: {number: 1, version: 1}}}
      @form =
        number: 1
        version: 1
        slug: "form-1"
        fields: [
          {kind: 'info', details: {text: "Information here"}},
          {kind: 'short-answer', details: {label: "Answer"}}
          {kind: 'long-answer', details: {label: "Answer"}}
        ]

    describe "invalid form", ->
      Given ->
        @$httpBackend.expectGET("/api/forms/1/versions/1").respond(404, '')
        @$controller('FormEditorController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms")

    describe "locked form", ->
      Given ->
        @form.locked = true
        @$httpBackend.expectGET("/api/forms/1/versions/1").respond(form: @form)
        @$controller('FormEditorController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})
      When -> @$httpBackend.flush()
      Then -> expect(@$location.path()).toEqual("/admin/forms/1/versions/1")

    describe "valid form", ->
      Given ->
        @$httpBackend.expectGET("/api/forms/1/versions/1").respond(form: @form)
        @$controller('FormEditorController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})

      describe "before init", ->
        Then -> expect(@$scope.formLoaded).toBeFalsy()
        Then -> expect(@$scope.form).toBeNull()
        Then -> expect(@$scope.projects).toEqual({})
        Then -> expect(@$scope.md2html).toEqual(@MarkdownService.md2html)

      describe "after init", ->
        Given -> @$httpBackend.flush()
        Then -> expect(@$scope.formLoaded).toBeTruthy()
        Then -> expect(@$scope.form.version).toEqual(1)
        Then -> expect(@$scope.form.slug).toEqual('form-1')
        Then -> expect(@$scope.lastSaved).toBeNull()
        Then -> expect(@$scope.projects).toEqual(@projects)

        describe "#editSettings", ->
          When -> @$scope.editSettings()
          Then -> expect(@$scope.editingSettings).toBeTruthy()
          Then -> expect(@$scope.editingField).toBeFalsy()

          describe "followed by #editField", ->
            When -> @$scope.editField(0)
            Then -> expect(@$scope.editingSettings).toBeFalsy()
            Then -> expect(@$scope.editingField).toBeTruthy()

        describe "#editField", ->
          When -> @$scope.editField(0)
          Then -> expect(@$scope.editingFieldIndex).toEqual(0)
          Then -> expect(@$scope.editingField.kind).toEqual('info')
          Then -> expect(@$scope.editingField.details.text).toEqual('Information here')
          Then -> expect(@$scope.editingSettings).toBeFalsy()

          describe "followed by #editSettings", ->
            When -> @$scope.editSettings()
            Then -> expect(@$scope.editingSettings).toBeTruthy()
            Then -> expect(@$scope.editingField).toBeFalsy()

        describe "#dirty", ->
          describe "when form hasn't been changed", ->
            Then -> expect(@$scope.dirty).toBeFalsy()

          describe "when form has been changed", ->
            When -> @$scope.$apply => @$scope.form.name = 'New Name'
            Then -> expect(@$scope.dirty).toBeTruthy()

        describe "#save", ->
          When ->
            @$httpBackend
              .expectPUT("/api/forms/1/versions/1", form: @form)
              .respond(201, date: new Date())
          When -> @$scope.save()
          When -> @$httpBackend.flush(1)
          Then -> expect(@$scope.lastSaved).not.toBeNull()

        describe "#removeField", ->
          Given -> @fields = @$scope.form.fields.length
          When -> @$scope.editField(0)
          When -> @$scope.removeField(0)
          Then -> expect(@$scope.form.fields.length).toEqual(@fields - 1)
          Then -> expect(@$scope.editingField).toBeNull()
          Then -> expect(@$scope.editingFieldIndex).toBeNull()

        describe "#moveFieldUp", ->
          describe "when the first field", ->
            Given -> @field = @$scope.form.fields[0]
            When -> @$scope.editField(0)
            When -> @$scope.moveFieldUp(0)
            Then -> expect(@$scope.form.fields[0]).toEqual(@field)
            Then -> expect(@$scope.editingFieldIndex).toEqual(0)

          describe "when not the first field", ->
            Given -> @field = @$scope.form.fields[1]
            When -> @$scope.editField(1)
            When -> @$scope.moveFieldUp(1)
            Then -> expect(@$scope.form.fields[0]).toEqual(@field)
            Then -> expect(@$scope.editingFieldIndex).toEqual(0)

        describe "#moveFieldDown", ->
          describe "when the last field", ->
            Given -> @lastFieldIndex = @$scope.form.fields.length - 1
            Given -> @field = @$scope.form.fields[@lastFieldIndex]
            When -> @$scope.editField(@lastFieldIndex)
            When -> @$scope.moveFieldDown(@lastFieldIndex)
            Then -> expect(@$scope.form.fields[@lastFieldIndex]).toEqual(@field)
            Then -> expect(@$scope.editingFieldIndex).toEqual(@lastFieldIndex)

          describe "when not the last field", ->
            Given -> @field = @$scope.form.fields[1]
            When -> @$scope.editField(1)
            When -> @$scope.moveFieldDown(1)
            Then -> expect(@$scope.form.fields[2]).toEqual(@field)
            Then -> expect(@$scope.editingFieldIndex).toEqual(2)

        describe "#addField", ->
          Given -> @fieldsLength = @$scope.form.fields.length

          describe "for info field", ->
            When -> @$scope.addField('info')
            Then -> expect(@$scope.form.fields.length).toEqual(@fieldsLength + 1)
            Then -> expect(@$scope.form.fields[@fieldsLength].kind).toEqual('info')
            Then -> expect(@$scope.editingField).toEqual(@$scope.form.fields[@fieldsLength])
            Then -> expect(@$scope.editingFieldIndex).toEqual(@fieldsLength)
            Then -> expect(@$scope.form.fields[@fieldsLength].details.required).toBeFalsy()

          describe "for a non-info field", ->
            When -> @$scope.addField('short-answer')
            Then -> expect(@$scope.form.fields[@fieldsLength].details.required).toBeTruthy()

        describe "#tryDone", ->
          Then -> expect(@$scope.displayWarning).toBeFalsy()

          describe "when form is dirty", ->
            Given -> @$scope.dirty = true
            When -> @$scope.tryDone()
            Then -> expect(@$scope.displayWarning).toBeTruthy()

          describe "when form is not dirty", ->
            Given -> @done = spyOn(@$scope, 'done')
            When -> @$scope.tryDone()
            Then -> expect(@done).toHaveBeenCalled()

  describe "#done", ->
    When ->
      @$controller('FormEditorController', {@$scope, @$route, @$location, @FormsService, @MarkdownService})

    describe "when form number and version are not defined", ->
      Given -> @$route = {current: {params: {}}}
      When -> @$scope.done()
      Then -> expect(@$location.path()).toEqual("/admin/forms")

    describe "when form number and version are both defined", ->
      Given -> @$route = {current: {params: {number: 1, version: 1}}}
      Given -> @$httpBackend.expectGET("/api/forms/1/versions/1").respond(form: {})
      When -> @$httpBackend.flush()
      When -> @$scope.done()
      Then -> expect(@$location.path()).toEqual("/admin/forms/1/versions/1")

