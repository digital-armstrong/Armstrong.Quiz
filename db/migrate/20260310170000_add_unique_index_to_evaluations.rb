class AddUniqueIndexToEvaluations < ActiveRecord::Migration[7.1]
  def change
    add_index :evaluations, %i[admin_id user_id], unique: true
  end
end

