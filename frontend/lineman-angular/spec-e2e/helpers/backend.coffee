client = require("request-json").newClient(browser.baseUrl)

exports.post = (url, data) ->
  client.post(url, data, ->)

