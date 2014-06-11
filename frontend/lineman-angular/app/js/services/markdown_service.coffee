angular
  .module('admin')
  .factory 'MarkdownService', ($sce) ->

    mdConverter = new Markdown.Converter()

    md2html: (mdText) -> $sce.trustAsHtml(mdConverter.makeHtml(mdText ? ''))
