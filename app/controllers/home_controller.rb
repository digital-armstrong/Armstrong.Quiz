# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @categories = Category.order(:title)
    if user_signed_in?
      if current_user.admin?
        redirect_to admin_root_path
      else
        @attempt = current_user.quiz_attempts.where(completed: false).first
        @completed_category_ids = current_user.quiz_attempts.where(completed: true).pluck(:category_id).compact
        if @attempt
          redirect_to quiz_path
        else
          render :index
        end
      end
    else
      render :index
    end
  end
end