class CreateIncomeTaxAccounts < ActiveRecord::Migration
  def change
    create_table :income_tax_accounts do |t|
      t.references :scenario, index: true
      t.references :owner,    index: true

      t.string :filing_status
    end
  end
end
