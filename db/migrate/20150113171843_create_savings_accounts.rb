class CreateSavingsAccounts < ActiveRecord::Migration
  def change
    create_table :savings_accounts do |t|
      t.references :scenario
      t.belongs_to :income_account, index: true

      t.string     :starting_month
      t.decimal    :starting_balance, precision: 9, scale: 2
      t.string     :monthly_interest_rate

      t.timestamps null: false
    end
  end
end

