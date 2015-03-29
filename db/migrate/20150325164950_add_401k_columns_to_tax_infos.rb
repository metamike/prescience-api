class Add401kColumnsToTaxInfos < ActiveRecord::Migration
  def change
    add_column :tax_infos, :annual_401k_contribution_limit, :integer
    add_column :tax_infos, :annual_401k_contribution_limit_growth_rate, :string
  end
end
