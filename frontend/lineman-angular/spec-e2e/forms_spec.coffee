protractor = require("protractor")
require "jasmine-given"

formFactory = require "./factories/form"
responseFactory = require "./factories/form_response"
page = new (require "./page-objects/forms_page")()

describe "forms home", ->
  Given -> formFactory.clear()

  describe "general page contents", ->
    Given -> page.get()

    describe "sidebar", ->
      Then -> expect(page.sidebarTitle.getText()).toEqual("Forms Home")
      And -> expect(page.sidebar.getText()).toMatch(/actions/i)
      And -> expect(page.sidebarLink('Create a New Form').isPresent()).toBeTruthy()

  describe "when there are no forms", ->
    Given -> page.get()
    Then -> expect(page.formRows.count()).toEqual(0)
    And -> expect(page.noFormsNotice.isPresent()).toBeTruthy()

  describe "when there is at least one form", ->
    Given -> formFactory.create(forms: 2)
    Given -> page.get()
    Then -> expect(page.formRows.count()).toEqual(2)
    And -> expect(page.noFormsNotice.isPresent()).toBeFalsy()
    And -> expect(page.formInfo('name').isPresent()).toBeTruthy()
    And -> expect(page.formInfo('project').isPresent()).toBeTruthy()
    And -> expect(page.formInfo('username').isPresent()).toBeTruthy()
    And -> expect(page.formInfo('date').isPresent()).toBeTruthy()
    And -> expect(page.formInfo('numResponses').getText()).toEqual('0')

  describe "when at least one form was published", ->
    Given -> formFactory.create(properties: published: true)
    Given -> page.get()
    Then -> expect(page.publishedCheck.isPresent()).toBeTruthy()
    And -> expect(page.prevPublishedCheck.isPresent()).toBeFalsy()

  describe "when at least one form was previously published", ->
    Given ->
      @forms = formFactory.build(versions: 2)
      @forms[0].published = true
      formFactory.save(@forms)
    Given -> page.get()
    Then -> expect(page.publishedCheck.isPresent()).toBeFalsy()
    And -> expect(page.prevPublishedCheck.isPresent()).toBeTruthy()

  describe "when there is at least one response", ->
    Given -> @form = formFactory.create()[0]
    Given -> responseFactory.create(@form, responses: 2)
    Given -> page.get()
    Then -> expect(page.formInfo('numResponses').getText()).toEqual('2')
    And -> expect(page.responsesLink.isPresent()).toBeTruthy()

