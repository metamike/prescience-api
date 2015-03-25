class LinkStockBundlesToInvestmentAccounts < ActiveRecord::Migration
  def change
    rename_column :stock_bundles, :mutual_fund_id, :investment_account_id
  end
end
