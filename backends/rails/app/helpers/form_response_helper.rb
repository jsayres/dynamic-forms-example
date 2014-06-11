module FormResponseHelper

  def md2html(text)
    markdown.render(text || "").html_safe
  end

  private

  def markdown
    @markdown = @markdown || Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end

end
