class AdminPage
  url: null
  isSetup: false
  sidebar: element(By.css('.sidebar'))
  sidebarTitle: element(By.css('.sidebar .title'))

  sidebarLink: (text) ->
    @sidebar.element(By.linkText(text))

  breadcrumbLink: (text) ->
    element(By.linkText(text.toUpperCase()))

  get: ->
    browser.get(@url)

module.exports = AdminPage
