protractor = require("protractor")
require "jasmine-given"
require "jasmine-only"

page = new (require "./page-objects/admin_home_page")()

describe "admin home", ->
  Given -> page.get()
  Then -> expect(page.title.getText()).toEqual("Admin Apps")
  And -> expect(page.appInfo('forms').isPresent()).toBeTruthy()
