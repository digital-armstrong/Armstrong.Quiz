# frozen_string_literal: true

class PagesController < ApplicationController
  def privacy
    @content = Rails.root.join("app/views/pages/privacy.md").read
  end
end
