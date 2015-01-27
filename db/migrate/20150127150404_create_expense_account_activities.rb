class CreateExpenseAccountActivities < ActiveRecord::Migration
  def change
    create_table :expense_account_activities do |t|
      t.references :expense_account, index: true

      t.string  :month
      t.decimal :amount, precision: 9, scale: 2

      t.timestamps null: false
    end
  end
end

