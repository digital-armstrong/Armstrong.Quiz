# frozen_string_literal: true

class AddStateToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :state, :string, default: "active", null: false
    add_index :users, :state
  end
end
