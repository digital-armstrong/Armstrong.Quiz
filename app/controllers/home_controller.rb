# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @sections = Section.enabled.order(:title).includes(categories: :questions)
    if user_signed_in? && current_user.student?
      @attempt = current_user.quiz_attempts.where(completed: false).first
      @completed_category_ids = current_user.quiz_attempts.where(completed: true).pluck(:category_id).compact
      redirect_to quiz_path if @attempt
    end
    render :index
  end
end