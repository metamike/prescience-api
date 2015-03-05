class AddOwnerIdToIncomeAccounts < ActiveRecord::Migration
  def change
    add_column :income_accounts, :owner_id, :integer
    add_index  :income_accounts, [:owner_id]
  end
end

