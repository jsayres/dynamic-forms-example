AdminPage = require "./admin_page"

class AdminHomePage extends AdminPage
  url: "/admin"
  title: element(By.css('h1.title'))

  appInfo: (appName) ->
    element(By.css("##{appName}-app-info"))

module.exports = AdminHomePage
