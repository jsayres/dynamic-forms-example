FormEditorPage = require "./form_editor_page"

class NewFormFromCopyPage extends FormEditorPage
  get: (options) ->
    @url = "/admin/forms/#{options?.form ? 1}/versions/#{options?.version ? 1}/new-form"
    browser.get(@url)

module.exports = NewFormFromCopyPage
