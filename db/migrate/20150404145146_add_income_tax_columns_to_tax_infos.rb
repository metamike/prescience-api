class AddIncomeTaxColumnsToTaxInfos < ActiveRecord::Migration
  def change
    add_column :tax_infos, :standard_deduction, :decimal, precision: 8, scale: 2
    add_column :tax_infos, :standard_deduction_growth_rate, :string
  end
end
