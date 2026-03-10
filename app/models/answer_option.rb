class AnswerOption < ApplicationRecord
  belongs_to :question
  has_many :user_answers, dependent: :nullify

  validates :body, presence: true
  validates :position, numericality: { only_integer: true, allow_nil: true }

  before_validation :set_position_if_blank, on: :create

  private

  def set_position_if_blank
    return if position.present?
    max_pos = question&.answer_options&.where.not(id: nil)&.maximum(:position) || 0
    self.position = max_pos + 1
  end
end
