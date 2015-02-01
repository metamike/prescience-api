class CreateIncomeAccounts < ActiveRecord::Migration
  def change
    create_table :income_accounts do |t|
      t.references :scenario

      t.string     :name
      t.string     :starting_month
      t.decimal    :annual_gross, precision: 8, scale: 2
      t.decimal    :annual_raise, precision: 3, scale: 3   # default: 0

      t.timestamps null: false
    end
  end
end

