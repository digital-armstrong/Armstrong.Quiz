# frozen_string_literal: true

class AddPoolTagToQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column :questions, :pool_tag, :integer, null: false, default: 0
    add_index :questions, :pool_tag
  end
end
