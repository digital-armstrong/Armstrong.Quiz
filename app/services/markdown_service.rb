# frozen_string_literal: true

class MarkdownService
  class << self
    def render(text)
      return "" if text.blank?

      doc = Commonmarker.parse(text)
      options = Commonmarker::Config::OPTIONS.deep_merge(render: { unsafe: true })
      doc.to_html(options: options)
    end
  end
end
