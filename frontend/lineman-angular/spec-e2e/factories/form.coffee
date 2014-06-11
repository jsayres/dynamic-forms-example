config = require("../../config/spec-e2e").config
projects = require("../../config/server").projects
backend = require("request-json").newClient(config.baseUrl)

defaults = (number, version) ->
  number: number
  version: version
  name: "Form #{number}"
  description: "Form description"
  project: chooseProject(projects)
  slug: "form-#{number}"
  username: "user#{number}"
  date: new Date()
  published: false
  current: false
  locked: false
  fields: [
    number: 1
    kind: "info"
    details:
      text: "This is sample form #{number}, version #{version}."
  ,
    number: 2
    kind: "short-answer"
    details:
      label: "Answer"
      question: "What is the answer?"
  ,
    number: 3
    kind: "long-answer"
    details:
      label: "Answer"
      question: "What is the answer?"
  ,
    number: 4
    kind: "single-choice"
    details:
      question: "What is the answer?"
      choices: [{label: "A"}, {label: "B"}, {label: "C"}]
  ,
    number: 5
    kind: "multiple-choice"
    details:
      question: "What is the answer?"
      choices: [{label: "A"}, {label: "B"}, {label: "C"}]
  ,
    number: 6
    kind: "address"
    details:
      question: "What is your address?"
  ]

chooseProject = (projects) ->
  arr = (k for k, v of projects)
  arr[Math.floor(Math.random() * arr.length)]

buildForm = (number, version, properties) ->
  form = defaults(number, version)
  form[k] = v for k, v of properties
  form

clear = ->
  backend.post '/test-only/forms/clear', {}, (err, res, body) ->

save = (forms) ->
  backend.post '/test-only/forms/save', {forms: forms}, (err, res, body) ->

build = (options = {}) ->
  numForms = options.forms ? 1
  versionsPerForm = options.versions ? 1
  properties = options.properties ? {}
  forms = []
  for number in [1..numForms]
    for version in [1..versionsPerForm]
      properties.current = version is versionsPerForm
      forms.push(buildForm(number, version, properties))
  forms

create = (options) ->
  forms = build(options)
  save(forms)
  forms

exports.clear = clear
exports.save = save
exports.build = build
exports.create = create
