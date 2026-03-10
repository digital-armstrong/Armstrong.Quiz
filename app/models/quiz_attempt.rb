class QuizAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  has_many :user_answers, dependent: :destroy

  validate :only_one_active_attempt_per_user, on: :create
  validate :category_completed_only_once, on: :create

  def current_question
    return nil unless category_id
    answered_ids = user_answers.pluck(:question_id)
    category.questions.order(:position).where.not(id: answered_ids).first
  end

  def completed?
    completed && current_question.nil?
  end

  private

  def only_one_active_attempt_per_user
    return if completed
    return unless user && QuizAttempt.where(user_id: user_id).where(completed: false).exists?

    errors.add(:base, I18n.t("activerecord.errors.models.quiz_attempt.one_active_attempt"))
  end

  def category_completed_only_once
    return unless category_id && user_id
    return unless QuizAttempt.where(user_id: user_id, category_id: category_id, completed: true).exists?

    errors.add(:base, I18n.t("activerecord.errors.models.quiz_attempt.category_already_completed"))
  end
end
