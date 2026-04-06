# frozen_string_literal: true

module Admin
  class ResultsController < BaseController
    def index
      @students = User.students.active.includes(:profile).order(:email)
      @attempts_by_user = QuizAttempt.where(completed: true).group(:user_id).count

      user_ids = @students.pluck(:id)
      answers_scope = UserAnswer.joins(:quiz_attempt).where(quiz_attempts: { user_id: user_ids })
      countable_scope = answers_scope.countable_for_stats
      @total_answers_by_user = answers_scope.group("quiz_attempts.user_id").count
      @total_countable_by_user = countable_scope.group("quiz_attempts.user_id").count
      countable_by_user = answers_scope.countable_for_stats
        .includes(:answer_option, :quiz_attempt, question: :answer_options)
        .to_a
        .group_by { |ua| ua.quiz_attempt.user_id }
      @correct_answers_by_user = countable_by_user.transform_values { |list| list.count(&:correct_for_stats?) }

      @overall_completed = QuizAttempt.where(completed: true).count
      countable = UserAnswer.countable_for_stats
      @overall_total_answers = countable.count
      @overall_correct = UserAnswer.correct_countable(countable)
      @overall_correct_percent = @overall_total_answers.positive? ? (@overall_correct.to_f / @overall_total_answers * 100).round(1) : 0
      @overall_completed_by_day = QuizAttempt.where(completed: true).group_by_day(:completed_at).count
      @overall_correct_vs_incorrect = {
        t("admin.dashboard.correct") => @overall_correct,
        t("admin.dashboard.incorrect") => @overall_total_answers - @overall_correct
      }

      # График лидеров: студент → % правильных (только те, у кого есть учитываемые ответы)
      @students_correct_percent = {}
      @students.each do |user|
        total = @total_countable_by_user[user.id].to_i
        next if total.zero?

        correct = @correct_answers_by_user[user.id].to_i
        @students_correct_percent[helpers.fio_short(user)] = (correct.to_f / total * 100).round(1)
      end
      @students_correct_percent = @students_correct_percent.sort_by { |_, pct| -pct }.to_h
    end

    def show
      @user = User.find(params[:user_id])
      @attempts = @user.quiz_attempts.where(completed: true).order(completed_at: :desc)
      @latest_attempt = @attempts.first

      attempts_scope = @user.quiz_attempts
      answers_scope = UserAnswer.where(quiz_attempt: attempts_scope)
      countable_scope = answers_scope.countable_for_stats
      @completed_count = attempts_scope.where(completed: true).count
      @total_answers = countable_scope.count
      @pending_answers_count = answers_scope.pending_admin_review.count
      @correct_answers = UserAnswer.correct_countable(answers_scope)
      @correct_percent = @total_answers.positive? ? (@correct_answers.to_f / @total_answers * 100).round(1) : 0

      @correct_vs_incorrect = {
        t("admin.dashboard.correct") => @correct_answers,
        t("admin.dashboard.incorrect") => @total_answers - @correct_answers
      }
      countable_list = countable_scope.preload(:answer_option, question: :answer_options).to_a
      total_countable_by_category = countable_list.group_by { |ua| ua.question.category.title }.transform_values(&:size)
      correct_by_category = countable_list.group_by { |ua| ua.question.category.title }.transform_values { |list| list.count(&:correct_for_stats?) }
      @answers_percent_by_category = {}
      total_countable_by_category.each do |cat, total|
        correct = correct_by_category[cat].to_i
        @answers_percent_by_category[cat] = total.positive? ? (correct.to_f / total * 100).round(1) : 0
      end

      # Ответы по категориям для удобной проверки
      all_answers = answers_scope
        .includes(:question, :answer_option, question: %i[category answer_options])
        .joins(question: :category)
        .order("categories.title", "questions.id")
      @user_answers_by_category = all_answers.group_by { |ua| ua.question.category }.sort_by { |cat, _| cat.title }.to_h
    end
  end
end