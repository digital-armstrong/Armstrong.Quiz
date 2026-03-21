# frozen_string_literal: true

class CreateSectionsAndAddToCategories < ActiveRecord::Migration[8.1]
  def up
    create_table :sections do |t|
      t.string :title, null: false
      t.text :description

      t.timestamps
    end

    add_reference :categories, :section, foreign_key: true, null: true

    default_section = Section.create!(
      title: "Общее",
      description: "Категории без явного раздела (создано при обновлении схемы)."
    )
    Category.where(section_id: nil).update_all(section_id: default_section.id)

    change_column_null :categories, :section_id, false
  end

  def down
    remove_reference :categories, :section, foreign_key: true
    drop_table :sections
  end
end
