class AddMoreTaxColumnsToTaxInfos < ActiveRecord::Migration
  def change
    add_column :tax_infos, :max_capital_loss_growth_rate, :string
    add_column :tax_infos, :personal_exemption_income_limit_growth_rate, :string
    add_column :tax_infos, :personal_exemption_growth_rate, :string
  end
end
