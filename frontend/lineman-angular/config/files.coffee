# Exports a function which returns an object that overrides the default &
#   plugin file patterns (used widely through the app configuration)

# To see the default definitions for Lineman's file paths and globs, see:
#   - https://github.com/linemanjs/lineman/blob/master/config/files.coffee

module.exports = (lineman) ->
  #Override file patterns here
  coffee:
    app: ["app/js/app.coffee", "app/js/**/*.coffee"]
    generated: "generated/assets/js/app.coffee.js"
    generatedSpec: "generated/assets/js/spec.coffee.js"
    generatedSpecHelpers: "generated/assets/js/spec-helpers.coffee.js"
  css:
    concatenated: "generated/assets/css/app.css"
    minified: "dist/assets/css/app.css"
    minifiedWebRelative: "assets/css/app.css"
  img:
    root: "assets/img"
  js:
    app: ["app/js/app.js", "app/js/**/*.js"]
    vendor: [
      "vendor/bower/jquery/dist/jquery.js",
      "vendor/bower/angular/angular.js",
      "vendor/bower/angular-cookies/angular-cookies.js",
      "vendor/bower/angular-mocks/angular-mocks.js",
      "vendor/bower/angular-resource/angular-resource.js",
      "vendor/bower/angular-route/angular-route.js",
      "vendor/bower/angular-sanitize/angular-sanitize.js",
      "vendor/bower/foundation/js/foundation/foundation.js",
      "vendor/bower/foundation/js/foundation/foundation.topbar.js",
      "vendor/bower/pagedown/Markdown.Converter.js",
      "vendor/js/**/*.js"
    ]
    concatenated: "generated/assets/js/app.js"
    concatenatedSpec: "generated/assets/js/spec.js"
    minified: "dist/assets/js/app.js"
    minifiedWebRelative: "assets/js/app.js"
  sass:
    generatedVendor: "generated/assets/css/vendor.sass.css"
    generatedApp: "generated/assets/css/app.sass.css"
  webfonts:
    foundation: "vendor/bower/foundation-icon-fonts/foundation-icons.{eot,svg,ttf,woff}"
    root: "assets/webfonts"

