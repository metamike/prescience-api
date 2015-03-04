class Scenario < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_many :savings_accounts
  has_many :income_accounts
  has_many :expense_accounts
  has_many :mutual_funds

  serialize :projections_start, Month

  validates :projections_start, presence: true

  after_initialize :init

  attr_reader :report

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
      savings_balance: savings_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.ending_balance(month) },
      expenses: expense_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.amount(month) },
      stock_performance: mutual_funds.reduce(BigDecimal.new('0')) { |a, e| a + e.total_performance(month) },
      stock_balance: mutual_funds.reduce(BigDecimal.new('0')) { |a, e| a + e.ending_balance(month) }
   }
  end

  def run_lifecycle(month)
    # TODO make work
    # if month >= projections_start
    #   expenses = upcoming_expenses(month)
    #   starting_balance = savings_accounts.reduce(0) { |a, e| a + e.start_balance(month) }
    #   buy_sell = starting_balance - expenses

    #   expense_accounts.each { |a| a.transact(month) }

    #   # TODO iterate through each fund and try to subtract the amount
    #   if buy_sell < 0   # sell
    #     raise 'Need to sell stock but no mutual funds available' if mutual_funds.empty?
    #     mutual_funds.first.sell(month, -buy_sell)
    #   else   # buy
    #     mutual_funds.first.buy(month, buy_sell)
    #   end
    # end

    income_accounts.each { |a| a.project(month) }
    expense_accounts.each { |a| a.project(month) }
    expense_accounts.each { |a| a.transact(month) }
    savings_accounts.each { |a| a.project(month) }
    mutual_funds.each { |a| a.project(month) }
  end

  private

  def upcoming_expenses(month)
    current = month
    upcoming_expenses = 0
    6.times do
      expense_accounts.each do |account|
        account.project(current)
        upcoming_expenses += account.amount(current)
      end
      current = current.next
    end
    upcoming_expenses > 0 ? upcoming_expenses : 0
  end

  def init
    @report = {}
    # FIXME Hack to make sure savings accounts are linked correctly
    income_accounts.each do |account|
      account.savings_account = savings_accounts.find { |a| a.id == account.savings_account.id }
    end
  end

end
