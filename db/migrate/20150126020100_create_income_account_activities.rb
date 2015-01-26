class CreateIncomeAccountActivities < ActiveRecord::Migration
  def change
    create_table :income_account_activities do |t|
      t.references :income_account, index: true

      t.string  :month
      t.decimal :gross, precision: 9, scale: 2

      t.timestamps null: false
    end
  end
end

