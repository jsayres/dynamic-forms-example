describe "MarkdownService", ->
  Given ->
    module('admin')
    inject (@$sce, @MarkdownService) ->
      @trustAsHtml = spyOn(@$sce, 'trustAsHtml').andCallThrough()

  describe "#md2html", ->
    When -> @result = @MarkdownService.md2html('# test text')
    Then -> expect(@trustAsHtml).toHaveBeenCalled()
    Then -> expect(@$sce.getTrustedHtml(@result)).toEqual('<h1>test text</h1>')

