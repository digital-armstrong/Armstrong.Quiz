class Category < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :nullify

  validates :title, presence: true
end
