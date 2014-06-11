protractor = require("protractor")
require "jasmine-given"

formFactory = require "./factories/form"
responseFactory = require "./factories/form_response"
page = new (require "./page-objects/form_responses_page")()

describe "form responses list", ->
  Given -> formFactory.clear()

  describe "when the form doesn't exist", ->
    Given -> page.get()
    Then -> expect(browser.getCurrentUrl()).toMatch(/\/admin\/forms$/)

  describe "when the form exists", ->
    Given -> [@form] = formFactory.create()

    describe "general page contents", ->
      Given -> responseFactory.create(@form, responses: 3)
      Given -> page.get()

      describe "sidebar", ->
        Then -> expect(page.sidebarTitle.getText()).toEqual("Form Responses")
        And -> expect(page.sidebar.getText()).toMatch(/actions/i)
        And -> expect(page.sidebarLink('Download CSV').isPresent()).toBeTruthy()

      describe "responses list", ->
        Then -> expect(page.responseRows.count()).toEqual(3)
        And -> expect(page.responseLink(1).isPresent()).toBeTruthy()
        And -> expect(page.responseInfo('username').isPresent()).toBeTruthy()
        And -> expect(page.responseInfo('date').isPresent()).toBeTruthy()

    describe "when there are no responses", ->
      Given -> page.get()
      Then -> expect(page.noResponsesNotice.isPresent()).toBeTruthy()
      And -> expect(page.responsesTable.isPresent()).toBeFalsy()

    describe "response rendering for short-answer", ->
      Given -> [@form] = formFactory.create
        properties:
          fields: [{kind: 'short-answer', details: {label: 'Answer'}}]
      Given -> responseFactory.create @form,
        properties:
          fieldResponses: [{details: {answer: 'Testing'}}]
      Given -> page.get()
      Then -> expect(page.tableHeader(4).getText()).toEqual('Answer')
      And -> expect(page.tableCell(4, 1).getText()).toEqual('Testing')

    describe "response rendering for long-answer", ->
      Given -> [@form] = formFactory.create
        properties:
          fields: [{kind: 'long-answer', details: {label: 'Answer'}}]
      Given -> responseFactory.create @form,
        properties:
          fieldResponses: [{details: {answer: 'Testing'}}]
      Given -> page.get()
      Then -> expect(page.tableHeader(4).getText()).toEqual('Answer')
      And -> expect(page.tableCell(4, 1).getText()).toEqual('Testing')

    describe "response rendering for single-choice", ->
      Given -> [@form] = formFactory.create
        properties:
          fields: [
            kind: 'single-choice'
            details:
              question: 'Which one?'
              choices: [{label: 'A'}, {label: 'B'}]
           ]
      Given -> responseFactory.create @form,
        properties:
          fieldResponses: [{details: {answer: 'B'}}]
      Given -> page.get()
      Then -> expect(page.tableHeader(4).getText()).toEqual('Which one?')
      And -> expect(page.tableCell(4, 1).getText()).toEqual('B')

    describe "response rendering for multiple-choice", ->
      Given -> [@form] = formFactory.create
        properties:
          fields: [
            kind: 'multiple-choice'
            details:
              question: 'Which ones?'
              choices: [{label: 'A'}, {label: 'B'}]
           ]
      Given -> responseFactory.create @form,
        properties:
          fieldResponses: [
            details:
              answers: [{label: 'A', selected: false}, {label: 'B', selected: true}]
          ]
      Given -> page.get()
      Then -> expect(page.tableHeader(4).getText()).toEqual('Which ones?')
      And -> expect(page.tableCell(4, 1).getText()).not.toContain('A')
      And -> expect(page.tableCell(4, 1).getText()).toContain('B')

    describe "response rendering for address", ->
      Given -> [@form] = formFactory.create
        properties:
          fields: [{kind: 'address', details: {question: 'Enter address'}}]
      Given -> responseFactory.create @form,
        properties:
          fieldResponses: [
            details:
              addressLine1: '123 Fake St'
              addressLine2: 'Unit 666'
              city: 'Hoboken'
              state: 'NJ'
              zip: '07030'
          ]
      Given -> page.get()
      Then -> expect(page.tableHeader(4).getText()).toEqual('Enter address')
      And -> expect(page.tableCell(4, 1).getText()).toContain('123 Fake St')
      And -> expect(page.tableCell(4, 1).getText()).toContain('Unit 666')
      And -> expect(page.tableCell(4, 1).getText()).toContain('Hoboken')
      And -> expect(page.tableCell(4, 1).getText()).toContain('NJ')
      And -> expect(page.tableCell(4, 1).getText()).toContain('07030')

