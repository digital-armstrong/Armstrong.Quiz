# frozen_string_literal: true

class AllowNullAnswerOptionInUserAnswers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :user_answers, :answer_option_id, true
  end
end
