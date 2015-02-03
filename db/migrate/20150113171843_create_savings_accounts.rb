class CreateSavingsAccounts < ActiveRecord::Migration
  def change
    create_table :savings_accounts do |t|
      t.references :scenario
      t.belongs_to :income_account, index: true
      t.string     :starting_month
      t.decimal    :starting_balance, precision: 9, scale: 2
      t.decimal    :interest_rate,    precision: 7, scale: 6

      t.timestamps null: false
    end
  end
end

