module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    MarkdownService.render(text).html_safe
  end
end
