class Question < ApplicationRecord
  belongs_to :category
  has_many :answer_options, -> { order(:position) }, dependent: :destroy
  has_many :user_answers, dependent: :destroy

  enum :pool_tag, { standard: 0, difficult: 1, special: 2 }, default: :standard

  def self.human_pool_tag_name(value)
    I18n.t("activerecord.enums.question.pool_tag.#{value}")
  end

  accepts_nested_attributes_for :answer_options, allow_destroy: true, reject_if: :all_blank

  after_save :assign_answer_option_positions, if: :saved_change_to_id?

  validates :title, presence: true

  private

  def assign_answer_option_positions
    answer_options.reload.order(:id).each_with_index do |opt, i|
      opt.update_column(:position, i + 1) if opt.position != i + 1
    end
  end
end
