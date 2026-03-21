# frozen_string_literal: true

class AddEnabledToSections < ActiveRecord::Migration[8.1]
  def change
    add_column :sections, :enabled, :boolean, null: false, default: true
  end
end
