FormEditorPage = require "./form_editor_page"

class NewFormPage extends FormEditorPage
  url: "/admin/forms/new"
  get: ->
    browser.get(@url)

module.exports = NewFormPage
