AdminPage = require "./admin_page"

class FormResponsesPage extends AdminPage
  responsesTable: element(By.css('#form-responses-list'))
  responseRows: element.all(By.repeater('response in responses'))
  noResponsesNotice: element(By.css('#no-responses-notice'))

  responseInfo: (property) ->
    element(By.css('tbody > tr:first-of-type')).element(By.binding("response.#{property}"))

  tableHeader: (col) ->
    element(By.css("thead > tr:first-of-type > th:nth-of-type(#{col})"))

  tableCell: (col, row = 1) ->
    element(By.css("tbody > tr:nth-of-type(#{row}) > td:nth-of-type(#{col})"))

  responseLink: (row = 1) ->
    @tableCell(1, row).element(By.linkText(row.toString()))

  get: (options) ->
    @url = "/admin/forms/#{options?.form ? 1}/versions/#{options?.version ? 1}/responses"
    super()

module.exports = FormResponsesPage
