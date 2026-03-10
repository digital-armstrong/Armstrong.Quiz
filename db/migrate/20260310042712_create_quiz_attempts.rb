class CreateQuizAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :completed
      t.datetime :completed_at

      t.timestamps
    end
  end
end
