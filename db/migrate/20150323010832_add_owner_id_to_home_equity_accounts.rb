class AddOwnerIdToHomeEquityAccounts < ActiveRecord::Migration
  def change
    add_column :home_equity_accounts, :owner_id, :integer
  end
end
