angular
  .module("admin")
  .controller 'AdminController', ($scope, $http, $window) ->

    $scope.logout = ->
      $http.delete('/logout').success ->
        $window.location.href = '/'
