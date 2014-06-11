AdminPage = require "./admin_page"

class FormVersionPage extends AdminPage
  nextVersionLink: element(By.css('#version-navigation .next-link'))
  prevVersionLink: element(By.css('#version-navigation .prev-link'))
  versionsLink: element(By.css('#version-navigation .versions-link'))
  publishedStatus: element(By.css('.form-published'))
  unpublishedStatus: element(By.css('.form-unpublished'))
  lockedStatus: element(By.css('.form-locked'))

  formInfo: (property) ->
    element(By.binding("form.#{property}"))

  field: (kind) ->
    element(By.css(".#{kind}-field"))

  get: (options) ->
    @url = "/admin/forms/#{options?.form ? 1}/versions/#{options?.version ? 1}"
    super()

module.exports = FormVersionPage
