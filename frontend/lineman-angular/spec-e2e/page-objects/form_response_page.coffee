AdminPage = require "./admin_page"

class FormResponsePage extends AdminPage
  nextResponseLink: element(By.css('#response-navigation .next-link'))
  prevResponseLink: element(By.css('#response-navigation .prev-link'))
  responsesLink: element(By.css('#response-navigation .responses-link'))
  shortAnswerResponse: element(By.css('.short-answer-field input'))
  longAnswerResponse: element(By.css('.long-answer-field textarea'))
  addressResponse: (name) ->
    element(By.css(".address-field input[name=#{name}]"))

  singleChoiceResponse: (choice) ->
    element(By.css(".single-choice-field input[value=#{choice}]"))

  multipleChoiceResponse: (choice) ->
    element(By.css(".multiple-choice-field input[value=#{choice}]"))

  responseInfo: (property) ->
    element(By.binding("responses[responseIndex].#{property}"))

  formInfo: (property) ->
    element(By.binding("form.#{property}"))

  field: (kind) ->
    element(By.css(".#{kind}-field"))

  get: (options) ->
    @url = "/admin/forms/#{options?.form ? 1}/versions/#{options?.version ? 1}/responses/#{options?.response ? 1}"
    super()

module.exports = FormResponsePage
