class CreateHistoricalTaxInfos < ActiveRecord::Migration
  def change
    create_table :historical_tax_infos do |t|
      t.references :tax_info, index: true

      t.integer :year
      t.decimal :social_security_wage_limit,     precision: 9, scale: 2
      t.decimal :state_disability_wage_limit,    precision: 9, scale: 2
      t.decimal :annual_401k_contribution_limit, precision: 8, scale: 2
      t.decimal :standard_deduction,             precision: 8, scale: 2
      t.decimal :max_capital_loss,               precision: 7, scale: 2
      t.decimal :personal_exemption_income_limit_single, precision: 9, scale: 2
      t.decimal :personal_exemption_income_limit_married, precision: 9, scale: 2
      t.decimal :personal_exemption              precisision: 7, scale: 2

      t.timestamps null: false
    end
  end
end
