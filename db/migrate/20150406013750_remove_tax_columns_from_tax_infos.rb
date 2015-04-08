class RemoveTaxColumnsFromTaxInfos < ActiveRecord::Migration
  def change
    remove_column :tax_infos, :starting_year
    remove_column :tax_infos, :social_security_wage_limit
    remove_column :tax_infos, :state_disability_wage_limit
    remove_column :tax_infos, :annual_401k_contribution_limit
    remove_column :tax_infos, :standard_deduction
    remove_column :tax_infos, :max_capital_loss
  end
end
