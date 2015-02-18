class CreateStockBundle < ActiveRecord::Migration
  def change
    create_table :stock_bundles do |t|
      t.references :mutual_fund, index: true

      t.string  :month_bought
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps null: false
    end
  end
end

