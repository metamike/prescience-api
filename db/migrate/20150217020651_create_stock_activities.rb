class CreateStockActivities < ActiveRecord::Migration
  def change
    create_table :stock_activities do |t|
      t.references :stock_bundle, index: true

      t.string  :month
      t.decimal :sold,        precision: 10, scale: 2
      t.decimal :performance, precision: 9,  scale: 2
      t.decimal :dividends,   precision: 8,  scale: 2

      t.timestamps null: false
    end
  end
end

