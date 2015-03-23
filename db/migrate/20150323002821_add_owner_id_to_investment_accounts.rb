class AddOwnerIdToInvestmentAccounts < ActiveRecord::Migration
  def change
    add_column :investment_accounts, :owner_id, :integer
  end
end
