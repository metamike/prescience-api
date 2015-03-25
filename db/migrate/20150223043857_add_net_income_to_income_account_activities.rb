class AddNetIncomeToIncomeAccountActivities < ActiveRecord::Migration
  def change
    add_column :income_account_activities, :net, :decimal, precision: 9, scale: 2
  end
end
