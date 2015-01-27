class Scenario < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_many :savings_accounts
  has_many :income_accounts

  after_initialize :init_report

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
    run_lifecycle(month)
    @report[month] = {
      gross_income: income_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.gross(month) },
      interest: savings_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.interest(month) },
      savings_balance: savings_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.ending_balance(month) }
    }
  end

  def run_lifecycle(month)
    income_accounts.each { |account| account.project(month) }
    savings_accounts.each { |account| account.project(month) }
  end

  private

  def init_report
    @report = {}
  end

end
