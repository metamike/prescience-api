class AddIncomeTaxColumnsToIncomeTaxActivities < ActiveRecord::Migration
  def change
    add_column :income_tax_activities, :capital_net, :decimal, precision: 9, scale: 2
  end
end
