# frozen_string_literal: true

class QuizController < ApplicationController
  before_action :authenticate_user!
  before_action :require_student!
  before_action :set_attempt, only: %i[show answer]

  def show
    if @attempt.nil?
      redirect_to root_path, notice: t("quiz.choose_category")
      return
    end

    @question = @attempt.current_question
    if @question.nil?
      @attempt.update(completed: true, completed_at: Time.current)
      render :thank_you
    else
      @answer_options = @question.answer_options
      render :question
    end
  end

  def create
    authorize QuizAttempt, :create?
    category = Category.find_by(id: params[:category_id])
    unless category
      redirect_to root_path, alert: t("quiz.category_not_found")
      return
    end
    unless category.section.enabled?
      redirect_to root_path, alert: t("quiz.section_disabled")
      return
    end
    if category.questions.empty?
      redirect_to root_path, alert: t("quiz.category_no_questions")
      return
    end
    if current_user.quiz_attempts.where(category_id: category.id, completed: true).exists?
      redirect_to root_path, alert: t("quiz.category_already_completed")
      return
    end
    existing = current_user.quiz_attempts.where(completed: false).first
    if existing
      redirect_to quiz_path, notice: t("quiz.already_started")
    else
      current_user.quiz_attempts.create!(category: category, completed: false)
      redirect_to quiz_path, notice: t("quiz.started")
    end
  end

  def answer
    redirect_to quiz_path, alert: t("quiz.no_active_attempt") and return if @attempt.blank?

    @question = @attempt.category.questions.find(params[:question_id])
    comment = params[:comment].to_s.strip

    if @question.answer_options.any?
      answer_option = @question.answer_options.find(params[:answer_option_id])
      UserAnswer.create!(
        quiz_attempt_id: @attempt.id,
        question_id: @question.id,
        answer_option_id: answer_option.id,
        comment: comment.presence
      )
    else
      UserAnswer.create!(
        quiz_attempt_id: @attempt.id,
        question_id: @question.id,
        answer_option_id: nil,
        comment: comment.presence
      )
    end
    redirect_to quiz_path, notice: t("quiz.answer_saved")
  end

  private

  def set_attempt
    @attempt = current_user.quiz_attempts.where(completed: false).first
  end

  def require_student!
    return if current_user.student?

    redirect_to root_path, alert: t("pundit.not_authorized")
  end
end