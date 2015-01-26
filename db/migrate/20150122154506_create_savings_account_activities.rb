class CreateSavingsAccountActivities < ActiveRecord::Migration
  def change
    create_table :savings_account_activities do |t|
      t.references :savings_account, index: true

      t.string  :month
      t.decimal :interest,       precision: 9,  scale: 2
      t.decimal :ending_balance, precision: 11, scale: 2

      t.timestamps null: false
    end
  end
end
