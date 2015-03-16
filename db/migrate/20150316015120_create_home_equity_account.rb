class CreateHomeEquityAccount < ActiveRecord::Migration
  def change
    create_table :home_equity_accounts do |t|
      t.references :scenario, index: true

      t.string  :month_bought
      t.decimal :loan_amount,     precision: 10, scale: 2
      t.integer :loan_term_months
      t.decimal :interest_rate,   precision: 6, scale: 5

      t.timestamps null: false
    end
  end
end

