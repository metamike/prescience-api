class AddStartingMonthToScenarios < ActiveRecord::Migration
  def change
    add_column :scenarios, :starting_month, :string
  end
end

