# frozen_string_literal: true

class RemovePositionFromQuestions < ActiveRecord::Migration[8.1]
  def change
    remove_column :questions, :position, :integer
  end
end
