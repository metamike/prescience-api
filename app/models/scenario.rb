class Scenario < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_many :savings_accounts
  has_many :income_accounts

  # For each month, want:
  #   Gross Income
  #   Interest
  #   Other Income
  #   Taxes
  #   Net Income
  #   Investments
  #   Retirement Funds
  #   Expenses
  #
  #   Account Balances:
  #    - Savings
  #    - Investments
  #    - Retirement Funds
  #    - Equities
  #    - Mortgages
  # 
  def project(month)
    income_accounts.each { |account| account.project(month) }
    # TODO expense_accounts.each { |account| account.project(month) }
    savings_accounts.each { |account| account.project(month) }
    gross = income_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.gross(month) }
    interest = savings_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.gross(month) }
  end

end
