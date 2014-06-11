protractor = require("protractor")
require "jasmine-given"

formFactory = require "./factories/form"
responseFactory = require "./factories/form_response"
page = new (require "./page-objects/form_response_page")()

describe "view form response", ->
  Given -> formFactory.clear()

  describe "general page contents", ->
    Given -> [@form] = formFactory.create()
    Given -> [@response] = responseFactory.create(@form)
    Given -> page.get()

    describe "sidebar", ->
      Then -> expect(page.sidebarTitle.getText()).toEqual("View Response")
      And -> expect(page.sidebar.getText()).toMatch(/responses/i)
      And -> expect(page.sidebarLink('Forms Home').isPresent()).toBeTruthy()

    describe "response view", ->
      Then -> expect(page.formInfo('name').isPresent()).toBeTruthy()
      And -> expect(page.formInfo('project').isPresent()).toBeTruthy()
      And -> expect(page.formInfo('version').isPresent()).toBeTruthy()
      And -> expect(page.responseInfo('username').isPresent()).toBeTruthy()
      And -> expect(page.responseInfo('date').isPresent()).toBeTruthy()
      And -> expect(page.field('info').isPresent()).toBeTruthy()
      And -> expect(page.field('short-answer').isPresent()).toBeTruthy()
      And -> expect(page.field('long-answer').isPresent()).toBeTruthy()
      And -> expect(page.field('single-choice').isPresent()).toBeTruthy()
      And -> expect(page.field('multiple-choice').isPresent()).toBeTruthy()
      And -> expect(page.field('address').isPresent()).toBeTruthy()
      And -> expect(page.shortAnswerResponse.getAttribute('value')).toEqual(@response.fieldResponses[0].details.answer)
      And -> expect(page.longAnswerResponse.getAttribute('value')).toEqual(@response.fieldResponses[1].details.answer)
      And -> expect(page.singleChoiceResponse(@response.fieldResponses[2].details.answer).getAttribute('selected')).toBeTruthy()
      And ->
        for answer in @response.fieldResponses[3].details.answers
          choiceSelected = page.multipleChoiceResponse(answer.label).getAttribute('selected')
          if answer.selected
            expect(choiceSelected).toBeTruthy()
          else
            expect(choiceSelected).toBeFalsy()
      And -> expect(page.addressResponse('addressLine1').getAttribute('value')).toEqual(@response.fieldResponses[4].details.addressLine1)
      And -> expect(page.addressResponse('addressLine2').getAttribute('value')).toEqual(@response.fieldResponses[4].details.addressLine2)
      And -> expect(page.addressResponse('city').getAttribute('value')).toEqual(@response.fieldResponses[4].details.city)
      And -> expect(page.addressResponse('state').getAttribute('value')).toEqual(@response.fieldResponses[4].details.state)
      And -> expect(page.addressResponse('zip').getAttribute('value')).toEqual(@response.fieldResponses[4].details.zip)

  describe "response navigation", ->
    Given -> [@form] = formFactory.create()
    Given -> @responses = responseFactory.create(@form, responses: 2)

    describe "when on first response", ->
      Given -> page.get(response: 1)
      Then -> expect(page.responsesLink.isPresent()).toBeTruthy()
      And -> expect(page.nextResponseLink.isPresent()).toBeTruthy()
      And -> expect(page.prevResponseLink.isPresent()).toBeFalsy()

    describe "when on last response", ->
      Given -> page.get(response: 2)
      Then -> expect(page.responsesLink.isPresent()).toBeTruthy()
      And -> expect(page.nextResponseLink.isPresent()).toBeFalsy()
      And -> expect(page.prevResponseLink.isPresent()).toBeTruthy()

