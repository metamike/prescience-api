class AddOwnerToExpenses < ActiveRecord::Migration
  def change
    add_column :expense_accounts, :owner_id, :integer, index: true
  end
end
