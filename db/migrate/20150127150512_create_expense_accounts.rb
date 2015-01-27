class CreateExpenseAccounts < ActiveRecord::Migration
  def change
    create_table :expense_accounts do |t|
      t.references :scenario, index: true

      t.string  :starting_month
      t.decimal :annual_amount, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end

