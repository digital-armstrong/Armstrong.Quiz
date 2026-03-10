# frozen_string_literal: true

class AddCategoryIdToQuizAttempts < ActiveRecord::Migration[8.1]
  def change
    add_reference :quiz_attempts, :category, null: true, foreign_key: true
  end
end
