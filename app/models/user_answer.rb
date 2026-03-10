class UserAnswer < ApplicationRecord
  belongs_to :quiz_attempt
  belongs_to :question
  belongs_to :answer_option, optional: true

  validates :quiz_attempt_id, uniqueness: { scope: :question_id }

  # Ответы с вариантом или уже оценённые админом (admin_correct не nil)
  scope :countable_for_stats, -> {
    left_joins(:answer_option).where(
      "answer_options.id IS NOT NULL OR user_answers.admin_correct IS NOT NULL"
    )
  }

  def self.correct_countable(scope = all)
    scope.countable_for_stats.where(
      "(answer_options.correct = :yes) OR (user_answers.answer_option_id IS NULL AND user_answers.admin_correct = :yes)",
      yes: true
    ).count
  end

  def correct_for_stats?
    if answer_option_id?
      answer_option&.correct?
    else
      admin_correct == true
    end
  end
end
