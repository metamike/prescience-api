class CreateHomeEquityAccountActivities < ActiveRecord::Migration
  def change
    create_table :home_equity_account_activities do |t|
      t.references :home_equity_account, index: true

      t.string  :month
      t.decimal :principal,  precision: 8, scale: 2
      t.decimal :interest,   precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end

