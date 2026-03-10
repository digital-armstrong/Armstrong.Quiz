class CreateAnswerOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :answer_options do |t|
      t.references :question, null: false, foreign_key: true
      t.text :body
      t.boolean :correct
      t.integer :position

      t.timestamps
    end
  end
end
