class CreateIncomeAccounts < ActiveRecord::Migration
  def change
    create_table :income_accounts do |t|
      t.references :scenario

      t.string     :name
      t.string     :starting_month
      t.decimal    :annual_salary, precision: 8, scale: 2

      t.string     :annual_raise

      t.timestamps null: false
    end
  end
end

