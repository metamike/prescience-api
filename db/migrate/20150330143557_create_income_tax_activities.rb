class CreateIncomeTaxActivities < ActiveRecord::Migration
  def change
    create_table :income_tax_activities do |t|
      t.integer :year

      t.references :income_tax_account, index: true

      # Inputs
      t.string :filing_status
      t.decimal :wages, precision: 9, scale: 2
      t.decimal :taxable_interest, precision: 7, scale: 2
      t.decimal :taxable_dividends, precision: 7, scale: 2
      t.decimal :qualified_dividends, precision: 7, scale: 2
      t.decimal :short_term_capital_net, precision: 9, scale: 2
      t.decimal :long_term_capital_net, precision: 9, scale: 2

      # Outputs
      t.decimal :adjusted_gross_income, precision: 10, scale: 2
      t.decimal :taxable_income, precision: 10, scale: 2
      t.decimal :federal_income_tax, precision: 9, scale: 2
      t.decimal :federal_income_tax_refund, precision: 9, scale: 2
      t.decimal :state_income_tax, precision: 9, scale: 2
      t.decimal :state_income_tax_refund, precision: 9, scale: 2

      t.timestamps null: false
    end
  end
end
