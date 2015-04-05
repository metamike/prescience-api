class AddCapitalLossToTaxInfos < ActiveRecord::Migration
  def change
    add_column :tax_infos, :max_capital_loss, :decimal, precision: 7, scale: 2
  end
end
