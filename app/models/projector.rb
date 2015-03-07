class Projector

  attr_reader :report

  def initialize(scenario)
    @scenario = scenario
    @last_projected_month = nil
    @report = {}
  end

  def project(month)
    return if @last_projected_month && month < @last_projected_month

    from = @last_projected_month || @scenario.projections_start
    from.upto(month) do |_month|
      run_lifecycle(_month)
      @report[_month] = {
        gross_income: @scenario.income_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.gross(_month) },
        interest: @scenario.savings_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.interest(_month) },
        savings_balance: @scenario.savings_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.ending_balance(_month) },
        expenses: @scenario.expense_accounts.reduce(BigDecimal.new('0')) { |a, e| a + e.amount(_month) },
        stock_performance: @scenario.mutual_funds.reduce(BigDecimal.new('0')) { |a, e| a + e.total_performance(_month) },
        stock_balance: @scenario.mutual_funds.reduce(BigDecimal.new('0')) { |a, e| a + e.ending_balance(_month) }
     }
    end
    @last_projected_month = month
    @report
  end

  private

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

    @scenario.income_accounts.each { |a| a.project(month) }
    @scenario.income_accounts.each { |a| a.transact(month) }
    @scenario.expense_accounts.each { |a| a.project(month) }
    @scenario.expense_accounts.each { |a| a.transact(month) }
    @scenario.savings_accounts.each { |a| a.project(month) }
    @scenario.savings_accounts.each { |a| a.transact(month) }
    @scenario.mutual_funds.each { |a| a.project(month) }
    @scenario.mutual_funds.each { |a| a.transact(month) }
  end

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

end
