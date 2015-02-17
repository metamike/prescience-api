class CreateMutualFunds < ActiveRecord::Migration
  def change
    create_table :mutual_funds do |t|
      t.references :scenario, index: true

      t.string  :name
      t.string  :starting_month
      # assumes initial funds have been held longer than a year
      t.decimal :starting_balance, precision: 10, scale: 2
      t.string  :interest_rate

      t.timestamps null: false
    end
  end
end

