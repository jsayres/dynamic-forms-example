protractor = require("protractor")
require "jasmine-given"

formFactory = require "./factories/form"
responseFactory = require "./factories/form_response"
page = new (require "./page-objects/form_versions_page")()

describe "form versions list", ->
  Given -> formFactory.clear()

  describe "general page contents", ->
    Given -> formFactory.create(versions: 3)
    Given -> page.get()

    describe "sidebar", ->
      Then -> expect(page.sidebarTitle.getText()).toEqual("Form Versions")
      And -> expect(page.sidebar.getText()).toMatch(/actions/i)
      And -> expect(page.sidebarLink('Create a New Form').isPresent()).toBeTruthy()

    describe "versions list", ->
      Then -> expect(page.versionRows.count()).toEqual(3)
      And -> expect(page.versionInfo('name').isPresent()).toBeTruthy()
      And -> expect(page.versionInfo('version').isPresent()).toBeTruthy()
      And -> expect(page.versionInfo('project').isPresent()).toBeTruthy()
      And -> expect(page.versionInfo('username').isPresent()).toBeTruthy()
      And -> expect(page.versionInfo('date').isPresent()).toBeTruthy()
      And -> expect(page.versionInfo('numResponses').getText()).toEqual('0')

  describe "when there are no versions", ->
    Given -> page.get()
    Then -> expect(browser.getCurrentUrl()).toMatch(/\/admin\/forms$/)

  describe "when there is at least one response", ->
    Given -> @form = formFactory.create()[0]
    Given -> responseFactory.create(@form, responses: 2)
    Given -> page.get()
    Then -> expect(page.versionInfo('numResponses').getText()).toEqual('2')
    And -> expect(page.responsesLink.isPresent()).toBeTruthy()

