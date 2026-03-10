class Evaluation < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: "User"

  RECOMMENDATIONS = %w[ready prospective not_suitable].freeze

  before_save :recalculate_score

  validates :score, numericality: { only_integer: true, allow_nil: true }
  validates :technical_knowledge, :argumentation, :creative_thinking, :team_collaboration,
            :leadership, :execution, :quick_learning,
            numericality: { only_integer: true, in: 1..5, allow_nil: true }
  validates :recommendation, inclusion: { in: RECOMMENDATIONS, allow_nil: true }
  validates :user_id, uniqueness: { scope: :admin_id }

  private

  def recalculate_score
    criteria = [
      technical_knowledge,
      argumentation,
      creative_thinking,
      team_collaboration,
      leadership,
      execution,
      quick_learning
    ].compact

    self.score = if criteria.any?
                   (criteria.sum.to_f / criteria.size).round
                 else
                   nil
                 end
  end
end
