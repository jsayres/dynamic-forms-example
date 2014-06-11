protractor = require "protractor"
require "jasmine-given"

formFactory = require "./factories/form"
page = new (require "./page-objects/form_editor_page")()

describe "forms editor", ->
  Given -> formFactory.clear()

  describe "when form doesn't exist", ->
    When -> page.get()
    Then -> expect(browser.getCurrentUrl()).toMatch(/\/admin\/forms$/)

  describe "when form is locked", ->
    Given -> formFactory.create(properties: locked: true)
    When -> page.get()
    Then -> expect(browser.getCurrentUrl()).toMatch(/\/admin\/forms\/1\/versions\/1$/)

  describe "when form is not locked", ->
    Given -> formFactory.create()
    Given -> page.get()

    describe "general page contents", ->
      Then -> expect(page.formName.isPresent()).toBeTruthy()

      describe "sidebar", ->
        Then -> expect(page.sidebarTitle.getText()).toEqual("Edit Form")
        And -> expect(page.sidebarLink('Done').isPresent()).toBeTruthy()
        And -> expect(page.sidebarLink('Info').isPresent()).toBeTruthy()
        And -> expect(page.sidebarLink('Short Answer').isPresent()).toBeTruthy()
        And -> expect(page.sidebarLink('Long Answer').isPresent()).toBeTruthy()
        And -> expect(page.sidebarLink('Single Choice').isPresent()).toBeTruthy()
        And -> expect(page.sidebarLink('Multiple Choice').isPresent()).toBeTruthy()
        And -> expect(page.sidebarLink('Address').isPresent()).toBeTruthy()

    describe "edit form information", ->
      When -> page.formInfo.click()
      When -> page.formNameEditor.clear()
      When -> page.formNameEditor.sendKeys('New Form Name')
      Then -> expect(page.formName.getText()).toEqual('New Form Name')

    describe "invalid form information", ->
      describe "blank form name", ->
        When -> page.formInfo.click()
        When -> page.formNameEditor.clear()
        Then -> expect(page.formName.getAttribute('class')).toContain('no-form-name')
        Then -> expect(page.formNameEditor.getAttribute('class')).toContain('ng-invalid')
        Then -> expect(page.saveLink.isPresent()).toBeFalsy()

    describe "edit info field", ->
      When -> page.field('info').click()
      When -> page.fieldEditor('info', 'details.text').clear()
      When -> page.fieldEditor('info', 'details.text').sendKeys('Information')
      Then -> expect(page.fieldData('info', 'details.text').getText()).toEqual('Information')

    describe "edit short-answer field", ->
      When -> page.field('short-answer').click()

      describe "changing question text", ->
        When -> page.fieldEditor('short-answer', 'details.question').clear()
        When -> page.fieldEditor('short-answer', 'details.question').sendKeys("The Question")
        Then -> expect(page.fieldData('short-answer', 'details.question').getText()).toEqual("The Question")

      describe "changing label", ->
        When -> page.fieldEditor('short-answer', 'details.label').clear()
        When -> page.fieldEditor('short-answer', 'details.label').sendKeys("The Answer")
        Then -> expect(page.fieldData('short-answer', 'details.label').getText()).toEqual("The Answer")

    describe "edit long-answer field", ->
      When -> page.field('long-answer').click()

      describe "changing question text", ->
        When -> page.fieldEditor('long-answer', 'details.question').clear()
        When -> page.fieldEditor('long-answer', 'details.question').sendKeys("The Question")
        Then -> expect(page.fieldData('long-answer', 'details.question').getText()).toEqual("The Question")

      describe "changing label", ->
        When -> page.fieldEditor('long-answer', 'details.label').clear()
        When -> page.fieldEditor('long-answer', 'details.label').sendKeys("The Answer")
        Then -> expect(page.fieldData('long-answer', 'details.label').getText()).toEqual("The Answer")

    describe "edit single-choice field", ->
      When -> page.field('single-choice').click()

      describe "changing question text", ->
        When -> page.fieldEditor('single-choice', 'details.question').clear()
        When -> page.fieldEditor('single-choice', 'details.question').sendKeys("The Question")
        Then -> expect(page.fieldData('single-choice', 'details.question').getText()).toEqual("The Question")

      describe "changing labels", ->
        When -> page.choiceLabelEditors('single-choice').map (el, i) ->
          el.clear().then -> el.sendKeys("Answer #{i}")
        Then -> page.choiceLabels('single-choice').map (el, i) ->
          expect(el.getText()).toEqual("Answer #{i}")

      describe "adding a choice", ->
        When -> page.addChoiceButton('single-choice').click()
        Then -> expect(page.choiceLabels('single-choice').count()).toEqual(4)

      describe "removing a choice", ->
        When -> page.removeChoiceButtons('single-choice').first().click()
        Then -> expect(page.choiceLabels('single-choice').count()).toEqual(2)
        And -> expect(page.choiceLabels('single-choice').first().getText()).toEqual('B')

    describe "edit multiple-choice field", ->
      When -> page.field('multiple-choice').click()

      describe "changing question text", ->
        When -> page.fieldEditor('multiple-choice', 'details.question').clear()
        When -> page.fieldEditor('multiple-choice', 'details.question').sendKeys("The Question")
        Then -> expect(page.fieldData('multiple-choice', 'details.question').getText()).toEqual("The Question")

      describe "changing labels", ->
        When -> page.choiceLabelEditors('multiple-choice').map (el, i) ->
          el.clear().then -> el.sendKeys("Answer #{i}")
        Then -> page.choiceLabels('multiple-choice').map (el, i) ->
          expect(el.getText()).toEqual("Answer #{i}")

      describe "adding a choice", ->
        When -> page.addChoiceButton('multiple-choice').click()
        Then -> expect(page.choiceLabels('multiple-choice').count()).toEqual(4)

      describe "removing a choice", ->
        When -> page.removeChoiceButtons('multiple-choice').first().click()
        Then -> expect(page.choiceLabels('multiple-choice').count()).toEqual(2)
        And -> expect(page.choiceLabels('multiple-choice').first().getText()).toEqual('B')

    describe "edit address field", ->
      When -> page.field('address').click()

      describe "changing question text", ->
        When -> page.fieldEditor('address', 'details.question').clear()
        When -> page.fieldEditor('address', 'details.question').sendKeys("The Question")
        Then -> expect(page.fieldData('address', 'details.question').getText()).toEqual("The Question")

    describe "saving the form", ->
      describe "before changes are made", ->
        Then -> expect(page.saveLink.isPresent()).toBeFalsy()

      describe "after changes are made", ->
        When -> page.formInfo.click()
        When -> page.formNameEditor.sendKeys('x')
        Then -> expect(page.saveLink.isPresent()).toBeTruthy()

        describe "try saving the form", ->
          When -> page.saveLink.click()
          And -> expect(page.saveLink.isPresent()).toBeFalsy()

          describe "when another change is made", ->
            When -> page.formNameEditor.sendKeys('y')
            Then -> expect(page.saveLink.isPresent()).toBeTruthy()

    describe "making editor controls appear", ->
      When -> page.field('info').click()
      Then -> expect(page.fieldEditor('info', 'details.text').isPresent()).toBeTruthy()

      describe "making editor controls disappear", ->
        When -> page.clickOffFields()
        Then -> expect(page.fieldEditor('info').isPresent()).toBeFalsy()

    describe "removing a field", ->
      When -> page.field('single-choice').click()
      When -> page.removeFieldLink.click()
      Then -> expect(page.field('single-choice').isPresent()).toBeFalsy()
      And -> expect(page.fieldEditor('single-choice').isPresent()).toBeFalsy()

    describe "field movement", ->
      Given -> @fieldClass = page.fields().get(1).getAttribute('class')

      describe "moving a field up", ->
        When -> page.fields().get(1).click()
        When -> page.moveFieldUpLink.click()
        When -> page.clickOffFields()
        Then -> expect(page.fields().get(0).getAttribute('class')).toEqual(@fieldClass)

      describe "moving a field down", ->
        When -> page.fields().get(1).click()
        When -> page.moveFieldDownLink.click()
        When -> page.clickOffFields()
        Then -> expect(page.fields().get(2).getAttribute('class')).toEqual(@fieldClass)

      describe "no move up option for first field", ->
        When -> page.fields().first().click()
        Then -> expect(page.moveFieldUpLink.isPresent()).toBeFalsy()

      describe "no move down option for last field", ->
        When -> page.fields().last().click()
        Then -> expect(page.moveFieldDownLink.isPresent()).toBeFalsy()

    for field in ['info', 'short-answer', 'long-answer', 'single-choice', 'multiple-choice', 'address']
      do (field) ->
        describe "adding an #{field} field", ->
          linkName = field.replace('-', ' ').replace /\b./g, (char, i) -> char.toUpperCase()
          When -> page.addFieldLink(linkName).click()
          Then -> expect(page.fields().last().getAttribute('class')).toMatch("#{field}-field")
          And -> expect(page.fieldEditor(field).isPresent()).toBeTruthy()

    describe "selecting Done", ->
      describe "when the form is dirty", ->
        When -> page.formInfo.click()
        When -> page.formNameEditor.sendKeys('x')
        When -> page.doneLink.click()
        Then -> expect(page.unsavedWarning.isPresent()).toBeTruthy()

      describe "when the form is not dirty", ->
        When -> page.doneLink.click()
        Then -> expect(page.unsavedWarning.isPresent()).toBeFalsy()
        And -> expect(browser.getCurrentUrl()).toMatch(/\/admin\/forms\/1\/versions\/1$/)

