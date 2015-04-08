class AddWithholdingsToIncomeTaxActivities < ActiveRecord::Migration
  def change
    add_column :income_tax_activities, :federal_income_tax_withheld, :decimal, precision: 9, scale: 2
    add_column :income_tax_activities, :social_security_tax_withheld, :decimal, precision: 9, scale: 2
    add_column :income_tax_activities, :state_income_tax_withheld, :decimal, precision: 9, scale: 2
    add_column :income_tax_activities, :state_disability_tax_withheld, :decimal, precision: 9, scale: 2
    add_column :income_tax_activities, :real_estate_taxes, :decimal, precision: 8, scale: 2
    add_column :income_tax_activities, :mortgage_starting_balance, :decimal, precision: 10, scale: 2
    add_column :income_tax_activities, :mortgage_ending_balance, :decimal, precision: 10, scale: 2
    add_column :income_tax_activities, :personal_exemption_income_limit_single, :decimal, precision: 9, scale: 2
    add_column :income_tax_activities, :personal_exemption_income_limit_married, :decimal, precision: 9, scale: 2
  end
end
