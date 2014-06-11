protractor = require("protractor")
require "jasmine-given"

formFactory = require "./factories/form"
page = new (require "./page-objects/form_version_page")()

describe "form version preview", ->
  Given -> formFactory.clear()

  describe "general page contents", ->
    Given -> formFactory.create()
    Given -> page.get()

    describe "sidebar", ->
      Then -> expect(page.sidebarTitle.getText()).toEqual("View Form")
      And -> expect(page.versionsLink.isPresent()).toBeTruthy()
      And -> expect(page.sidebar.getText()).toMatch(/actions/i)
      And -> expect(page.sidebarLink('Publish').isPresent()).toBeTruthy()
      And -> expect(page.sidebarLink('Edit').isPresent()).toBeTruthy()
      And -> expect(page.sidebarLink('Copy to New Form').isPresent()).toBeTruthy()
      And -> expect(page.sidebarLink('Copy to New Version').isPresent()).toBeTruthy()
      And -> expect(page.sidebarLink('Create a New Form').isPresent()).toBeTruthy()

    describe "form view", ->
      Then -> expect(page.formInfo('name').isPresent()).toBeTruthy()
      And -> expect(page.formInfo('project').isPresent()).toBeTruthy()
      And -> expect(page.formInfo('version').isPresent()).toBeTruthy()
      And -> expect(page.formInfo('username').isPresent()).toBeTruthy()
      And -> expect(page.formInfo('date').isPresent()).toBeTruthy()
      And -> expect(page.publishedStatus.isPresent()).toBeFalsy()
      And -> expect(page.unpublishedStatus.isPresent()).toBeTruthy()
      And -> expect(page.lockedStatus.isPresent()).toBeFalsy()
      And -> expect(page.field('info').isPresent()).toBeTruthy()
      And -> expect(page.field('short-answer').isPresent()).toBeTruthy()
      And -> expect(page.field('long-answer').isPresent()).toBeTruthy()
      And -> expect(page.field('single-choice').isPresent()).toBeTruthy()
      And -> expect(page.field('multiple-choice').isPresent()).toBeTruthy()
      And -> expect(page.field('address').isPresent()).toBeTruthy()

  describe "when on first version", ->
    Given -> formFactory.create(versions: 2)
    Given -> page.get(version: 1)
    Then -> expect(page.versionsLink.isPresent()).toBeTruthy()
    And -> expect(page.nextVersionLink.isPresent()).toBeTruthy()
    And -> expect(page.prevVersionLink.isPresent()).toBeFalsy()

  describe "when on last version", ->
    Given -> formFactory.create(versions: 2)
    Given -> page.get(version: 2)
    Then -> expect(page.versionsLink.isPresent()).toBeTruthy()
    And -> expect(page.nextVersionLink.isPresent()).toBeFalsy()
    And -> expect(page.prevVersionLink.isPresent()).toBeTruthy()

  describe "when version doesn't exist", ->
    Given -> page.get()
    Then -> expect(browser.getCurrentUrl()).toMatch(/\/admin\/forms$/)

  describe "when already published", ->
    Given -> formFactory.create(properties: published: true)
    Given -> page.get()
    Then -> expect(page.publishedStatus.isPresent()).toBeTruthy()
    And -> expect(page.unpublishedStatus.isPresent()).toBeFalsy()
    And -> expect(page.sidebarLink('Unpublish').isPresent()).toBeTruthy()
    And -> expect(page.sidebarLink('Publish').isPresent()).toBeFalsy()

    describe "when clicking Unpublish", ->
      When -> page.sidebarLink('Unpublish').click()
      Then -> expect(page.publishedStatus.isPresent()).toBeFalsy()
      And -> expect(page.unpublishedStatus.isPresent()).toBeTruthy()
      And -> expect(page.sidebarLink('Unpublish').isPresent()).toBeFalsy()
      And -> expect(page.sidebarLink('Publish').isPresent()).toBeTruthy()

  describe "when not already published", ->
    Given -> formFactory.create(properties: published: false)
    Given -> page.get()
    Then -> expect(page.publishedStatus.isPresent()).toBeFalsy()
    And -> expect(page.unpublishedStatus.isPresent()).toBeTruthy()
    And -> expect(page.sidebarLink('Unpublish').isPresent()).toBeFalsy()
    And -> expect(page.sidebarLink('Publish').isPresent()).toBeTruthy()

    describe "when clicking Publish", ->
      When -> page.sidebarLink('Publish').click()
      Then -> expect(page.publishedStatus.isPresent()).toBeTruthy()
      And -> expect(page.unpublishedStatus.isPresent()).toBeFalsy()
      And -> expect(page.sidebarLink('Unpublish').isPresent()).toBeTruthy()
      And -> expect(page.sidebarLink('Publish').isPresent()).toBeFalsy()

  describe "when locked", ->
    Given -> formFactory.create(properties: locked: true)
    Given -> page.get()
    Then -> expect(page.lockedStatus.isPresent()).toBeTruthy()

  describe "when not locked", ->
    Given -> formFactory.create(properties: locked: false)
    Given -> page.get()
    Then -> expect(page.lockedStatus.isPresent()).toBeFalsy()

