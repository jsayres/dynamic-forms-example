AdminPage = require "./admin_page"

class FormVersionsPage extends AdminPage
  versionRows: element.all(By.repeater('version in versions'))
  responsesLink: element(By.css('a.form-responses'))

  versionInfo: (property) ->
    element(By.css('tbody > tr:first-of-type')).element(By.binding("version.#{property}"))

  get: (options) ->
    @url = "/admin/forms/#{options?.form ? 1}/versions"
    super()

module.exports = FormVersionsPage
