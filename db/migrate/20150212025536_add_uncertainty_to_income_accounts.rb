class AddUncertaintyToIncomeAccounts < ActiveRecord::Migration
  def change
    add_column :income_accounts, :annual_raise_uncertain, :boolean
    add_column :income_accounts, :annual_raise_mean, :decimal, precision: 3, scale: 3
    add_column :income_accounts, :annual_raise_stdev, :decimal, precision: 3, scale: 3
  end
end

