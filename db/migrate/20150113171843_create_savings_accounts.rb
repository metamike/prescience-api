class CreateSavingsAccounts < ActiveRecord::Migration
  def change
    create_table :savings_accounts do |t|
      t.references :scenario
      t.string     :starting_month
      t.decimal    :interest_rate,    precision: 7, scale: 4

      t.timestamps null: false
    end
    add_money :savings_accounts, :starting_balance
  end
end

