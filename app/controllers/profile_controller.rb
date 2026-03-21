# frozen_string_literal: true

class ProfileController < ApplicationController
  include UserAccountUpdates

  before_action :authenticate_user!
  before_action :prepare_user, only: %i[edit update]

  layout :profile_layout

  def show
    # Для наставников — список оценённых пользователей
    @evaluated_users = current_user.evaluations_given.includes(user: :profile).map(&:user).uniq if current_user.mentor?

    return unless current_user.student?

    attempts_scope = current_user.quiz_attempts
    answers_scope = UserAnswer.where(quiz_attempt: attempts_scope)

    countable_scope = answers_scope.countable_for_stats
    @completed_count = attempts_scope.where(completed: true).count
    @total_answers = countable_scope.count
    @correct_answers = UserAnswer.correct_countable(answers_scope)
    @correct_percent = @total_answers.positive? ? (@correct_answers.to_f / @total_answers * 100).round(1) : 0

    @correct_vs_incorrect = {
      t("profile.charts.correct") => @correct_answers,
      t("profile.charts.incorrect") => @total_answers - @correct_answers
    }
    answers_by_category = answers_scope.joins(question: :category).group("categories.title").count
    correct_by_category = countable_scope
      .where("(answer_options.correct = :yes) OR (user_answers.admin_correct = :yes)", yes: true)
      .joins(question: :category).group("categories.title").count
    @answers_percent_by_category = answers_by_category.to_h do |cat, total|
      correct = correct_by_category[cat].to_i
      pct = total.positive? ? (correct.to_f / total * 100).round(1) : 0
      [cat, pct]
    end
  end

  def edit
    @user = current_user
    @minimum_password_length = User.password_length.min
  end

  def update
    @user = current_user
    if update_user_account(@user, account_params)
      bypass_sign_in(@user, scope: :user) if account_params[:password].present?
      redirect_to profile_path, notice: t("profile.updated")
    else
      @minimum_password_length = User.password_length.min
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_layout
    current_user.admin_or_mentor? ? "admin" : "application"
  end

  def prepare_user
    current_user.build_profile if current_user.profile.nil?
  end

  def account_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :current_password,
      profile_attributes: %i[id first_name last_name middle_name]
    )
  end
end
