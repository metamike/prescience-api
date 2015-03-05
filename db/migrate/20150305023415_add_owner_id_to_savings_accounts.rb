class AddOwnerIdToSavingsAccounts < ActiveRecord::Migration
  def change
    add_column :savings_accounts, :owner_id, :integer
    add_index  :savings_accounts, [:owner_id]
  end
end

