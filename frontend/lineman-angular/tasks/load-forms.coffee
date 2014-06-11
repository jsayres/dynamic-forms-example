###
Task: load-forms
Description: load dummy form data
Dependencies: grunt
Contributor: @jsayres
###
module.exports = (grunt) ->
  grunt.registerTask "load-forms", "load dummy form data", (target) ->
    require('coffee-script')
    formFactory = require "#{process.cwd()}/spec-e2e/factories/form"
    responseFactory = require "#{process.cwd()}/spec-e2e/factories/form_response"
    done = @async()
    formFactory.clear()
    forms = formFactory.create(forms: 3, versions: 3)
    responseFactory.create(form, responses: Math.floor(Math.random() * 5)) for form in forms
