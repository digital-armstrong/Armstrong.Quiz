class UserAnswer < ApplicationRecord
  belongs_to :quiz_attempt
  belongs_to :question
  belongs_to :answer_option, optional: true

  serialize :selected_answer_option_ids, coder: JSON, type: Array

  validates :quiz_attempt_id, uniqueness: { scope: :question_id }

  # Ответы с вариантом, множественным выбором или уже оценённые админом (admin_correct не nil)
  scope :countable_for_stats, -> {
    left_joins(:answer_option).where(
      <<~SQL.squish
        answer_options.id IS NOT NULL
        OR (
          user_answers.selected_answer_option_ids IS NOT NULL
          AND user_answers.selected_answer_option_ids != ''
          AND user_answers.selected_answer_option_ids NOT IN ('[]', 'null')
        )
        OR user_answers.admin_correct IS NOT NULL
      SQL
    )
  }

  scope :pending_admin_review, -> {
    where(admin_correct: nil, answer_option_id: nil)
      .where(question_id: Question.where.missing(:answer_options).select(:id))
  }

  def self.correct_countable(scope = all)
    scope.countable_for_stats
      .preload(:answer_option, question: :answer_options)
      .count(&:correct_for_stats?)
  end

  def selected_ids_normalized
    ids = selected_answer_option_ids
    ids = [] if ids.blank?
    Array(ids).map(&:to_i).uniq
  end

  def correct_for_stats?
    if question.answer_options.empty?
      admin_correct == true
    elsif question.multiple_answers?
      correct_multiple_selection?
    elsif answer_option_id?
      answer_option&.correct?
    else
      false
    end
  end

  def chosen_answer?(option)
    if question.multiple_answers?
      selected_ids_normalized.include?(option.id)
    else
      answer_option_id == option.id
    end
  end

  private

  def correct_multiple_selection?
    correct_ids = question.answer_options.where(correct: true).pluck(:id).sort
    selected_ids_normalized.sort == correct_ids && correct_ids.any?
  end
end
