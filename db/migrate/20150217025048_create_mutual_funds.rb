class CreateMutualFunds < ActiveRecord::Migration
  def change
    create_table :mutual_funds do |t|
      t.references :scenario, index: true

      t.string  :name
      t.string  :starting_month
      t.string  :monthly_interest_rate
      t.string  :monthly_dividend_rate

      t.timestamps null: false
    end
  end
end

