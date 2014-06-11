angular.module("admin").config ($routeProvider, $locationProvider) ->

  $locationProvider.html5Mode(true)

  $routeProvider.when '/admin',
    templateUrl: 'admin.html'

  $routeProvider.when '/admin/forms',
    templateUrl: 'forms.html'
    controller: 'FormsController'

  $routeProvider.when '/admin/forms/:number/versions',
    templateUrl: 'form_versions.html'
    controller: 'FormVersionsController'

  $routeProvider.when '/admin/forms/:number/versions/:version',
    templateUrl: 'form_version.html'
    controller: 'FormVersionController'

  $routeProvider.when '/admin/forms/:number/versions/:version/edit',
    templateUrl: 'form_editor.html'
    controller: 'FormEditorController'

  $routeProvider.when '/admin/forms/:number/versions/:version/new-form',
    templateUrl: 'form_editor.html'
    controller: 'FormEditorController'

  $routeProvider.when '/admin/forms/:number/versions/:version/new-version',
    templateUrl: 'form_editor.html'
    controller: 'FormEditorController'

  $routeProvider.when '/admin/forms/new',
    templateUrl: 'form_editor.html'
    controller: 'FormEditorController'

  $routeProvider.when '/admin/forms/:number/versions/:version/responses',
    templateUrl: 'form_responses.html'
    controller: 'FormResponsesController'

  $routeProvider.when '/admin/forms/:number/versions/:version/responses/:responseNum',
    templateUrl: 'form_response.html'
    controller: 'FormResponseController'

  $routeProvider.otherwise(redirectTo: '/admin')
