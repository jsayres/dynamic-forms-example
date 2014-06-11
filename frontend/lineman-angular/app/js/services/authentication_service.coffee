angular
  .module("admin").factory 'AuthenticationService', ($http) ->
    authenticated: false
    login: (credentials) ->
      $http.post('/login', credentials).success(@onLoginSuccess)
    onLoginSuccess: ->
      @authenticated = true
    logout: ->
      $http.post('/logout')
