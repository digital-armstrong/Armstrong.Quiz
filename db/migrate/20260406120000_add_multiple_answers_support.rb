# frozen_string_literal: true

class AddMultipleAnswersSupport < ActiveRecord::Migration[8.1]
  def change
    add_column :questions, :multiple_answers, :boolean, null: false, default: false
    add_column :user_answers, :selected_answer_option_ids, :text
  end
end
