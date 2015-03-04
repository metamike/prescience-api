class AddProjectionsStartToScenarios < ActiveRecord::Migration
  def change
    add_column :scenarios, :projections_start, :string
  end
end

