class AddTaxColumnsToIncomeAccountActivities < ActiveRecord::Migration
  def change
    add_column :income_account_activities, :federal_income_tax,         :decimal, precision: 7, scale: 2
    add_column :income_account_activities, :social_security_tax,        :decimal, precision: 6, scale: 2
    add_column :income_account_activities, :medicare_tax,               :decimal, precision: 6, scale: 2
    add_column :income_account_activities, :state_income_tax,           :decimal, precision: 7, scale: 2
    add_column :income_account_activities, :state_disability_tax,       :decimal, precision: 6, scale: 2

    # benefits
    add_column :income_account_activities, :pretax_401k_contribution,   :decimal, precision: 6, scale: 2
    add_column :income_account_activities, :aftertax_401k_contribution, :decimal, precision: 6, scale: 2
  end
end

