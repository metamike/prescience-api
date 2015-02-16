class CreateExpenseAccounts < ActiveRecord::Migration
  def change
    create_table :expense_accounts do |t|
      t.references :scenario, index: true

      t.string  :name
      t.string  :starting_month
      t.decimal :starting_amount,   precision: 9, scale: 2  #9,999,999.99
      t.integer :year_interval   # default: 1
      t.string  :month_coefficients   # default: 1,1,..,1
      t.decimal :stdev_coefficient, precision: 4, scale: 3   # default: 0
      t.string  :rate_of_increase   # default: 0
      t.string  :increase_schedule   # default: monthly

      t.timestamps null: false
    end
  end
end

