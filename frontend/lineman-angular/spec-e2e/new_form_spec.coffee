protractor = require "protractor"
require "jasmine-given"

formFactory = require "./factories/form"
page = new (require "./page-objects/new_form_page")()

describe "new form", ->
  Given -> formFactory.clear()
  When -> page.get()
  Then -> expect(page.sidebarTitle.getText()).toEqual("New Form")
  And -> expect(page.fields().count()).toEqual(0)
  And -> expect(page.formInfo.getText()).toContain("New Form")
  And -> expect(page.publishedLabel.isPresent()).toBeFalsy()
  And -> expect(page.unpublishedLabel.isPresent()).toBeFalsy()
  And -> expect(page.saveLink.isPresent()).toBeFalsy()

  describe "when form is altered", ->
    When -> page.formInfo.click()
    When -> page.formNameEditor.sendKeys("1")
    Then -> expect(page.saveLink.isPresent()).toBeTruthy()

    describe "and then saved", ->
      When -> page.saveLink.click()
      Then -> expect(browser.getCurrentUrl()).toMatch('/admin/forms/1/versions/1/edit')

