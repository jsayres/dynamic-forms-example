describe "AdminController", ->

  Given ->
    module 'admin', ($provide) ->
      $provide.value('$window', {location: href: ''})
      null

    inject (@$controller, @$httpBackend, $rootScope, @$http, @$window) ->
      @$scope = $rootScope.$new()
      @$controller('AdminController', {@$scope, @$http, @$window})

  afterEach ->
    @$httpBackend.verifyNoOutstandingRequest()
    @$httpBackend.verifyNoOutstandingExpectation()

  describe "logging out", ->
    Given -> @$httpBackend.expectDELETE("/logout").respond(200, no: 'data')
    When -> @$scope.logout()
    When -> @$httpBackend.flush()
    Then -> expect(@$window.location.href).toEqual("/")

