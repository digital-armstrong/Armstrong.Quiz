# frozen_string_literal: true

class AddAdminCorrectToUserAnswers < ActiveRecord::Migration[8.1]
  def change
    add_column :user_answers, :admin_correct, :boolean, null: true
  end
end
