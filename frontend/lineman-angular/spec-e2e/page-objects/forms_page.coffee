AdminPage = require "./admin_page"

class FormsPage extends AdminPage
  url: "/admin/forms"
  noFormsNotice: element(By.css('#no-forms-notice'))
  publishedCheck: element(By.css('.published-check'))
  prevPublishedCheck: element(By.css('.prev-published-check'))
  formRows: element.all(By.repeater('form in forms'))
  responsesLink: element(By.css('a.form-responses'))

  formInfo: (property) ->
    element(By.css('tbody > tr:first-of-type')).element(By.binding("form.#{property}"))

module.exports = FormsPage
