class ConvertMutualFundsToSti < ActiveRecord::Migration
  def change
    rename_table :mutual_funds, :investment_accounts
    add_column :investment_accounts, :type, :string
  end
end
