# 
# Initialize api data vars
#

# General
username = 'user1'

# Forms
forms = []

getForm = (number, version) ->
  form = forms[number - 1]?[version - 1]
  form.responses = getResponses(form)
  form

getCurrentForms = ->
  currentForms = []
  for versions in forms
    published = false
    for version in versions
      published = true if version.published
      if version.current
        version.prevPublished = published and not version.published
        version.numResponses = getResponses(version).length
        currentForms.push(version)
        break
  currentForms

getVersions = (number) ->
  versions = forms[number - 1]

  if versions?
    for version in versions
      version.numResponses = getResponses(version).length
  versions

saveForm = (form) ->
  if not form.name?
    false
  else
    if not form.version?
      if form.number?
        form.version = getVersions(form.number).length + 1
      else
        form.number = forms.length + 1
        form.version = 1
      form.current = true
    form.username = username
    form.date = new Date()
    versions = forms[form.number - 1] ?= []
    f.current = false for f in versions
    versions[form.version - 1] = form

publishForm = (number, version) ->
  form = getForm(number, version)
  if form?
    (f.published = false) for f in getVersions(number)
    form.published = true
  else
    false

unpublishForm = (number, version) ->
  form = getForm(number, version)
  if form? then not (form.published = false) else false

resetForms = ->
  forms = []
  resetResponses()

# Responses
responses = []

getResponses = (form) ->
  responses[form.number - 1]?[form.version - 1] ? []

saveResponse = (response) ->
  versions = responses[response.formNumber - 1] ?= []
  versionResponses = versions[response.formVersion - 1] ?= []
  versionResponses.push(response)

resetResponses = ->
  responses = []

# CSV
createCSV = (form, formResponses) ->
  fieldHeaders = (csvHeader[field.kind](field.details) for field in nonInfoFields(form.fields))
  headerRow = ['User', 'Date'].concat(fieldHeaders).join(',')
  rows = for response in formResponses
    rowResponses = for fieldResponse, i in response.fieldResponses
      csvCell[nonInfoFields(form.fields)[i].kind](fieldResponse.details)
    [response.username, response.date].concat(rowResponses).join(',')
  [headerRow].concat(rows).join('\n')

questionWithLabel = (details) -> "\"#{[details.question, details.label].join('\n\n')}\""
questionOnly = (details) -> details.question
answerOnly = (details) -> details.answer
selectedAnswers = (details) ->
  "\"#{(answer.label for answer in details.answers when answer.selected).join(', ')}\""

nonInfoFields = (fields) -> (f for f in fields when f.kind isnt 'info')

csvHeader =
  'short-answer': questionWithLabel
  'long-answer': questionWithLabel
  'single-choice': questionOnly
  'multiple-choice': questionOnly

csvCell =
  'short-answer': answerOnly
  'long-answer': answerOnly
  'single-choice': answerOnly
  'multiple-choice': selectedAnswers

# Projects
projects =
  main: 'Main Site'
  subproject: 'Sub Project'

# 
# Routes
#
module.exports =
  projects: projects
  drawRoutes: (app) ->

    app.get '/api/forms', (req, res) ->
      res.json(forms: getCurrentForms())

    app.post '/api/forms', (req, res) ->
      form = req.body.form
      if saveForm(form)
        res.json(number: form.number, version: form.version)
      else
        res.json(403, error: 'Invalid form')

    app.get '/api/projects', (req, res) ->
      res.json(projects: projects)

    app.get '/api/forms/:number/versions', (req, res) ->
      versions = getVersions(parseInt(req.params.number))
      if versions?
        res.json(forms: versions)
      else
        res.json(404, error: "Form not found")

    app.get '/api/forms/:number/versions/:version', (req, res) ->
      form = getForm(parseInt(req.params.number), parseInt(req.params.version))
      if form?
        res.json(form: form)
      else
        res.json(404, error: "Form version not found")

    app.put '/api/forms/:number/versions/:version', (req, res) ->
      form = req.body.form
      if saveForm(form)
        res.json(date: form.date)
      else
        res.json(403, error: 'Invalid form')

    app.post '/api/forms/:number/versions/:version/publish', (req, res) ->
      if publishForm(parseInt(req.params.number), parseInt(req.params.version))
        res.json(published: true)
      else
        res.json(404, error: "Form version not found")

    app.post '/api/forms/:number/versions/:version/unpublish', (req, res) ->
      if unpublishForm(parseInt(req.params.number), parseInt(req.params.version))
        res.json(published: false)
      else
        res.json(404, error: "Form version not found")

    app.get '/api/forms/:number/versions/:version/responses', (req, res) ->
      form = getForm(parseInt(req.params.number), parseInt(req.params.version))
      if form?
        res.json(form: form, responses: getResponses(form))
      else
        res.json(404, error: "Form not found")

    #
    # Logging out
    #
    app.delete '/logout', (req, res) ->
      res.redirect('/')

    #
    # CSV Download
    #
    app.get '/api/forms/:number/versions/:version/responses.csv', (req, res) ->
      form = getForm(parseInt(req.params.number), parseInt(req.params.version))
      if form?
        formResponses = getResponses(form)
        csv = createCSV(form, formResponses)
        res.set
          'Content-Type': 'text/csv'
          'Content-Disposition': 'attachment; filename="responses.csv"'
        res.send(csv)
      else
        res.json(404, message: "Form not found")

    #
    # Special endpoints to help with pseudo e2e testing (sans real backend)
    #
    app.post '/test-only/forms/clear', (req, res) ->
      resetForms()
      res.json(message: 'test forms cleared')

    app.post '/test-only/forms/save', (req, res) ->
      saveForm(form) for form in req.body.forms
      res.json(message: 'test forms saved')

    app.post '/test-only/responses/clear', (req, res) ->
      resetResponses()
      res.json(message: 'test responses cleared')

    app.post '/test-only/responses/save', (req, res) ->
      saveResponse(response) for response in req.body.responses
      res.json(message: 'test responses saved')

