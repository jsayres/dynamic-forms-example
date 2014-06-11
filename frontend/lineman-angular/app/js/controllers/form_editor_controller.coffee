angular
  .module("admin")
  .controller 'FormEditorController', ($scope, $timeout, $route, $location, FormsService, MarkdownService) ->

    angular.extend $scope,
      number: parseInt($route.current.params.number)
      version: parseInt($route.current.params.version)
      newForm: $location.path().match(/new$/)?
      newFormFromCopy: $location.path().match(/new-form$/)?
      newVersionFromCopy: $location.path().match(/new-version$/)?
      form: null
      formLoaded: false
      projects: {}
      md2html: MarkdownService.md2html
      dirty: false
      lastSaved: null
      editingSettings: false
      editingField: null
      editingFieldIndex: null
      displayWarning: false
      protocol: -> $location.protocol()
      host: -> $location.host()
      port: -> $location.port()

      editSettings: (event) ->
        event?.stopPropagation()
        $scope.editingSettings = true
        $scope.editingField = null
        $scope.editingFieldIndex = null

      editField: (index, event) ->
        event?.stopPropagation()
        $scope.editingField = $scope.form.fields[index]
        $scope.editingFieldIndex = index
        $scope.editingSettings = false

      getFormVersion: (number, version) ->
        FormsService.getFormVersion(number, version)
          .success (data) ->
            setForm switch
              when $scope.newFormFromCopy then FormsService.newForm(data.form)
              when $scope.newVersionFromCopy then FormsService.newVersion(data.form)
              else data.form
          .error ->
            $location.path("/admin/forms")

      save: ->
        FormsService.save($scope.form).success (data) ->
          if $scope.newForm or $scope.newFormFromCopy or $scope.newVersionFromCopy
            $location.path("/admin/forms/#{data.number}/versions/#{data.version}/edit")
          else
            unwatchForm()
            $scope.form.date = $scope.lastSaved = data.date
            watchForm()
            $scope.dirty = false

      done: ->
        if isNaN($scope.number) or isNaN($scope.version)
          $location.path("/admin/forms")
        else
          $location.path("/admin/forms/#{$scope.number}/versions/#{$scope.version}")

      tryDone: ->
        if $scope.dirty
          $scope.displayWarning = true
        else
          $scope.done()

      blurEditing: () ->
        $scope.editingSettings = false
        $scope.editingField = null

      removeField: (index) ->
        $scope.form.fields.splice(index, 1)
        $scope.editingField = $scope.editingFieldIndex = null

      moveFieldUp: (index) ->
        if index > 0
          field = $scope.form.fields.splice(index, 1)[0]
          $scope.form.fields.splice(index - 1, 0, field)
          $scope.editingFieldIndex = index - 1

      moveFieldDown: (index) ->
        if index < $scope.form.fields.length - 1
          field = $scope.form.fields.splice(index, 1)[0]
          $scope.form.fields.splice(index + 1, 0, field)
          $scope.editingFieldIndex = index + 1

      addField: (kind) ->
        newField = kind: kind, details: {required: kind != 'info'}
        $scope.form.fields.push(newField)
        $scope.editingField = newField
        $scope.editingFieldIndex = $scope.form.fields.length - 1
        $timeout -> $('.content').scrollTop($('.field:last-child').position().top)

    formWatcher = null
    watchForm = ->
      formWatcher = $scope.$watch 'form', (newVal, oldVal) ->
        $scope.dirty = switch
          when newVal is oldVal then $scope.newFormFromCopy || $scope.newVersionFromCopy
          else true
      , true
    unwatchForm = ->
      formWatcher?()

    setForm = (form) ->
      if form.locked
        $location.path("/admin/forms/#{form.number}/versions/#{form.version}")
      else
        unwatchForm()
        $scope.form = form
        $scope.formLoaded = true
        watchForm()

    FormsService.getProjects().success (data) ->
      $scope.projects = data.projects
      if $scope.form? and not $scope.form.project?
        unwatchForm()
        $scope.form.project = (k for k, v of $scope.projects)[0]
        watchForm()

    if $scope.newForm
      setForm(FormsService.newForm())
    else if isNaN($scope.number) or isNaN($scope.version)
      $location.path("/admin/forms")
    else
      $scope.getFormVersion($scope.number, $scope.version)

