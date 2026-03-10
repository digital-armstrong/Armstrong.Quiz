# frozen_string_literal: true

class ProfileController < ApplicationController
  before_action :authenticate_user!

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

    @completed_by_day = attempts_scope.where(completed: true).group_by_day(:completed_at).count
    @correct_vs_incorrect = {
      t("profile.charts.correct") => @correct_answers,
      t("profile.charts.incorrect") => @total_answers - @correct_answers
    }
    @answers_by_category = answers_scope.joins(question: :category).group("categories.title").count
    @correct_by_category = countable_scope
      .where("(answer_options.correct = :yes) OR (user_answers.admin_correct = :yes)", yes: true)
      .joins(question: :category).group("categories.title").count
  end
end
