class Category < ApplicationRecord
  belongs_to :section, inverse_of: :categories

  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :nullify

  validates :title, presence: true
end
