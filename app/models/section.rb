# frozen_string_literal: true

class Section < ApplicationRecord
  has_many :categories, -> { order(:title) }, dependent: :restrict_with_error, inverse_of: :section

  scope :enabled, -> { where(enabled: true) }

  validates :title, presence: true
end
