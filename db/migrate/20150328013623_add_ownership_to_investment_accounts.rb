class AddOwnershipToInvestmentAccounts < ActiveRecord::Migration
  def change
    add_column :investment_accounts, :active, :boolean
  end
end
