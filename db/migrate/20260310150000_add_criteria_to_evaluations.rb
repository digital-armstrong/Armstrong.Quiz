# frozen_string_literal: true

class AddCriteriaToEvaluations < ActiveRecord::Migration[8.1]
  def change
    add_column :evaluations, :technical_knowledge, :integer
    add_column :evaluations, :argumentation, :integer
    add_column :evaluations, :creative_thinking, :integer
    add_column :evaluations, :team_collaboration, :integer
    add_column :evaluations, :leadership, :integer
    add_column :evaluations, :execution, :integer
    add_column :evaluations, :quick_learning, :integer
    add_column :evaluations, :recommendation, :string
  end
end
