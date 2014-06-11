AdminPage = require "./admin_page"

class FormEditorPage extends AdminPage
  formInfo: element(By.css('.form-info'))
  formName: element(By.binding('form.name'))
  formNameEditor: element(By.model('form.name'))
  projectEditor: element(By.model('form.project'))
  descriptionEditor: element(By.model('form.description'))
  publishedLabel: element(By.css('.form-published'))
  unpublishedLabel: element(By.css('.form-unpublished'))
  saveLink: element(By.linkText('Save'))
  doneLink: element(By.linkText('Done'))
  removeFieldLink: element(By.css('.remove-field'))
  moveFieldUpLink: element(By.css('.move-field-up'))
  moveFieldDownLink: element(By.css('.move-field-down'))
  unsavedWarning: element(By.css('#unsaved-warning'))

  addFieldLink: (kind) ->
    element(By.linkText(kind))

  clickOffFields: ->
    browser.actions().mouseMove(@formInfo.getWebElement(), 0, -1).click().perform()

  fields: (kind) ->
    fieldClass = if kind? then ".#{kind}-field" else ".field"
    element.all(By.css(fieldClass))

  field: (kind, index = 0) ->
    fieldClass = if kind? then "#{kind}-field" else "field"
    element(By.xpath("//form/div[contains(@class, '#{fieldClass}')][#{index + 1}]"))

  fieldData: (kind, property, index = 0) ->
    @field(kind, index).element(By.binding("field.#{property}"))

  fieldEditor: (kind, property) ->
    base = element(By.css(".#{kind}-field-editor"))
    if property? then base.element(By.model("editingField.#{property}")) else base

  choiceLabels: (kind, index = 0) ->
    @field(kind, index).all(By.binding('choice.label'))

  choiceLabelEditors: (kind) ->
    element(By.css(".#{kind}-field-editor")).all(By.model('choice.label'))

  addChoiceButton: (kind) ->
    element(By.css(".#{kind}-field-editor .add-choice"))

  removeChoiceButtons: (kind) ->
    element.all(By.css(".#{kind}-field-editor .remove-choice"))

  get: (options) ->
    @url = "/admin/forms/#{options?.form ? 1}/versions/#{options?.version ? 1}/edit"
    super()

module.exports = FormEditorPage
