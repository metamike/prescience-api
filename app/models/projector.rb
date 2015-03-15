class Projector

  def initialize(scenario)
    @scenario = scenario
    @last_projected_month = nil
    @report = {}
  end

  def project(month)
    return if @last_projected_month && month < @last_projected_month

    from = @last_projected_month || @scenario.starting_month
    from.upto(month) do |_month|
      _month < @scenario.projections_start ? project_historicals(_month) : run_lifecycle(_month)
      @report[_month] = generate_report(_month)
    end
    @last_projected_month = month
    @report
  end

  def report(month)
    @report[month]
  end

  private

  def project_historicals(month)
    [@scenario.income_accounts, @scenario.expense_accounts, @scenario.savings_accounts,
        @scenario.mutual_funds].each do |bundle|
      bundle.each { |a| a.project(month) }
    end
  end

  def run_lifecycle(month)
    buy_or_sell_stock(month)

    [@scenario.income_accounts, @scenario.expense_accounts, @scenario.savings_accounts,
        @scenario.mutual_funds].each do |bundle|
      bundle.each { |a| a.project(month) }
      bundle.each { |a| a.transact(month) }
    end
  end

  def buy_or_sell_stock(month)
    expenses = upcoming_expenses(month)
    liquid_funds = @scenario.savings_accounts.reduce(0) { |a, e| a + e.start_balance(month) }
    surplus_funds = liquid_funds - expenses

    if surplus_funds < 0
      # sell
      raise "Need to sell stock to raise #{-surplus_funds}, but there is only #{mutual_fund_balance(month)} available" if mutual_fund_balance(month) < -surplus_funds
      @scenario.mutual_funds.first.sell(month, -surplus_funds)
    else
      # buy
      @scenario.mutual_funds.first.buy(month, surplus_funds) unless @scenario.mutual_funds.empty?
    end
  end

  def upcoming_expenses(month)
    current = month
    upcoming_expenses = 0
    6.times do
      @scenario.expense_accounts.each do |account|
        account.project(current)
        upcoming_expenses += account.amount(current)
      end
      current = current.next
    end
    upcoming_expenses > 0 ? upcoming_expenses : 0
  end

  def mutual_fund_balance(month)
    @scenario.mutual_funds.reduce(0) { |a, e| a + e.starting_balance(month) }
  end

  def generate_report(month)
    accumulator = SummaryAccumulator.new
    [@scenario.income_accounts, @scenario.expense_accounts, @scenario.savings_accounts,
        @scenario.mutual_funds].each do |bundle|
      bundle.each { |a| accumulator.merge(a.summary(month)) }
    end
    accumulator.summary
  end

end
