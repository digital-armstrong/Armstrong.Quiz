module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    MarkdownService.render(text).html_safe
  end

  def toast_css_class(flash_type)
    case flash_type.to_s
    when "notice", "success" then "bg-info/95 text-info-content border-info"
    when "alert", "error"   then "bg-error/95 text-error-content border-error"
    else "bg-base-100 border-base-300 shadow-lg"
    end
  end
end
