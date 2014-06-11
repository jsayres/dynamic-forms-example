config = require("../../config/spec-e2e").config
backend = require("request-json").newClient(config.baseUrl)

defaults = (form) ->
  formNumber: form.number
  formVersion: form.version
  username: "user1"
  date: new Date()
  fieldResponses: for field in form.fields when field.kind isnt 'info'
    fieldNumber: field.number
    details: responseGenerator[field.kind](field.details)

responseGenerator =
  'short-answer': -> {answer: 'An answer to a short-answer question'}
  'long-answer': -> {answer: 'An answer to a long-answer question'}
  'single-choice': (details) -> {answer: chooseSingle(details.choices)}
  'multiple-choice': (details) -> {answers: chooseMultiple(details.choices)}
  'address': (details) ->
    addressLine1: '123 Fake Street'
    addressLine2: 'Unit 666'
    city: 'Hoboken'
    state: 'NJ'
    zip: '07030'

chooseSingle = (choices) ->
  choices[Math.floor(Math.random() * choices.length)].label

chooseMultiple = (choices) ->
  ({label: choice.label, selected: Math.random() < 0.5} for choice in choices)

buildResponse = (form, properties) ->
  response = defaults(form)
  response[k] = v for k, v of properties
  response

clear = ->
  backend.post '/test-only/responses/clear', {}, (err, res, body) ->

save = (responses) ->
  backend.post '/test-only/responses/save', {responses: responses}, (err, res, body) ->

build = (form, options = {}) ->
  numResponses = options.responses ? 1
  properties = options.properties ? {}
  (buildResponse(form, properties) for r in [0...numResponses])

create = (form, options) ->
  responses = build(form, options)
  save(responses)
  responses

exports.clear = clear
exports.save = save
exports.build = build
exports.create = create
