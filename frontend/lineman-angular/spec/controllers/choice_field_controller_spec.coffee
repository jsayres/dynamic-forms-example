describe "ChoiceFieldController", ->
  Given ->
    module("admin")
    inject (@$controller, $rootScope) ->
      @$scope = $rootScope.$new()

  describe "when initialized without choices", ->
    Given -> @choices = [{label: 'A'}, {label: 'B'}, {label: 'C'}]
    Given ->
      @$scope.editingField = details: {}
      @$controller('ChoiceFieldController', {@$scope})
      @$scope.$digest()
    Then -> expect(@$scope.editingField.details.choices).toEqual(@choices)

  describe "when initialized with choices", ->
    Given -> @choices = [{label: '1'}, {label: '2'}]
    Given ->
      @$scope.editingField = details: choices: @choices
      @$controller('ChoiceFieldController', {@$scope})
    Then -> expect(@$scope.editingField.details.choices).toEqual(@choices)

    describe "#addChoice", ->
      When -> @$scope.addChoice()
      Then -> expect(@$scope.editingField.details.choices[2]).toEqual(label: '')

    describe "#removeChoice", ->
      describe "when there are available choices", ->
        When -> @$scope.removeChoice(1)
        Then -> expect(@$scope.editingField.details.choices).toEqual([label: '1'])

      describe "when there are no available choices", ->
        Given -> @$scope.editingField.details.choices = []
        When -> @$scope.removeChoice(0)
        Then -> expect(@$scope.editingField.details.choices).toEqual([label: ''])
