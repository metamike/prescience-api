class RemoveIncomeAccountIdFromSavingsAccounts < ActiveRecord::Migration
  def change
    remove_column :savings_accounts, :income_account_id
  end
end

