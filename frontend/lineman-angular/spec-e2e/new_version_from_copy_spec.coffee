protractor = require "protractor"
require "jasmine-given"

formFactory = require "./factories/form"
page = new (require "./page-objects/new_version_from_copy_page")()

describe "new version from copy", ->
  Given -> formFactory.clear()
  Given -> formFactory.create()
  When -> page.get()
  Then -> expect(page.sidebarTitle.getText()).toEqual("New Form Version")
  And -> expect(page.fields().count()).toBeGreaterThan(0)
  And -> expect(page.formInfo.getText()).toMatch(/.+/)
  And -> expect(page.publishedLabel.isPresent()).toBeFalsy()
  And -> expect(page.unpublishedLabel.isPresent()).toBeFalsy()
  And -> expect(page.saveLink.isPresent()).toBeTruthy()

  describe "when form is altered", ->
    When -> page.formInfo.click()
    When -> page.formNameEditor.sendKeys("1")
    Then -> expect(page.saveLink.isPresent()).toBeTruthy()

    describe "and then saved", ->
      When -> page.saveLink.click()
      Then -> expect(browser.getCurrentUrl()).toMatch('/admin/forms/1/versions/2/edit')

