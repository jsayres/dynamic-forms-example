FormEditorPage = require "./form_editor_page"

class NewVersionFromCopyPage extends FormEditorPage
  get: (options) ->
    @url = "/admin/forms/#{options?.form ? 1}/versions/#{options?.version ? 1}/new-version"
    browser.get(@url)

module.exports = NewVersionFromCopyPage
