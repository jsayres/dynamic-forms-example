angular
  .module("admin")
  .controller 'ChoiceFieldController', ($scope) ->

    $scope.$watch 'editingField', ->
      $scope.editingField.details.choices ?= [
        {label: 'A'},
        {label: 'B'},
        {label: 'C'}
      ]

    angular.extend $scope,
      addChoice: ->
        $scope.editingField.details.choices.push(label: '')

      removeChoice: (i) ->
        $scope.editingField.details.choices.splice(i, 1)
        if $scope.editingField.details.choices.length is 0 then $scope.addChoice()

