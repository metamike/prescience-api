#
# === Lifecycle ===
#
# if current funds < greater of necessary minimum (30K?) or upcoming expenses
#    if investments contains deficit
#       sell enough stock to meet deficit
#    else
#       INSUFFICIENT FUNDS (draw from IRA/401(k)?)
# else
#    actual surplus = max(necessary minimum, surplus)
#    apply surplus towards IRAs (prob. not roth) (always split funds amongst owners)
#       (amount = remaining amount / months remaining)
#    if remaining surplus
#       apply surplus towards 401(k) (split funds equally amongst owners)
#          (amount = remaining amount / months remaining)
#       if remaining surplus
#          apply surplus to investments
#
class Projector

  MINIMUM_SAVINGS = BigDecimal.new('30000')
  INFLATION = 0.03

  def initialize(scenario)
    @scenario = scenario
    @last_projected_month = nil
    @report = {}
  end

  def project(month)
    return @report[month] if @last_projected_month && month <= @last_projected_month

    from = @last_projected_month.try(:next) || @scenario.starting_month
    from.upto(month) do |_month|
      _month < @scenario.projections_start ? project_historicals(_month) : run_lifecycle(_month)
      @report[_month] = generate_report(_month)
    end
    @last_projected_month = month
    @report[month]
  end

  def report(month)
    @report[month]
  end

  private

  def project_historicals(month)
    [@scenario.income_accounts, @scenario.expense_accounts, @scenario.home_equity_accounts,
        @scenario.savings_accounts, @scenario.mutual_funds, @scenario.traditional401ks,
        @scenario.roth401ks].each do |bundle|
      bundle.each { |a| a.project(month) }
    end
  end

  def run_lifecycle(month)
    buy_or_sell_stock(month)

    [@scenario.income_accounts, @scenario.expense_accounts, @scenario.home_equity_accounts,
        @scenario.savings_accounts, @scenario.mutual_funds, @scenario.traditional401ks,
        @scenario.roth401ks].each do |bundle|
      bundle.each { |a| a.project(month) }
      bundle.each { |a| a.transact(month) }
    end
  end

  def buy_or_sell_stock(month)
    funds_needed = [minimum_savings_needed(month), upcoming_expenses(month)].max
    if current_savings(month) < funds_needed
      sell_mutual_funds(month, funds_needed - current_savings(month))
    else
      surplus_funds = current_savings(month) - funds_needed
      surplus_funds = contribute_to_401ks(month, surplus_funds)
      if surplus_funds > 0
        buy_mutual_funds(month, surplus_funds)
      end
    end
  end

  def minimum_savings_needed(month)
    MINIMUM_SAVINGS * (1 + INFLATION) ** (month.year_diff(@scenario.projections_start))
  end

  def current_savings(month)
    @scenario.savings_accounts.reduce(0) { |a, e| a + e.running_balance(month) }
  end

  def sell_mutual_funds(month, amount)
    raise "Need to sell stock to raise #{amount}, but there is only #{mutual_fund_balance(month)} available" if mutual_fund_balance(month) < amount
    current = amount
    @scenario.mutual_funds.each do |fund|
      to_sell = [current, fund.starting_balance(month)].min
      fund.sell(month, to_sell) if to_sell > 0
      current -= to_sell
      break if current <= 0
    end
    @scenario.savings_accounts_by_interest_rate.first.credit(month, amount)
  end

  def buy_mutual_funds(month, amount)
    return if @scenario.mutual_funds.empty?
    amount_per_fund = (amount / @scenario.mutual_funds.length).round(2)
    @scenario.mutual_funds.each do |fund|
      fund.buy(month, amount_per_fund)
      current = amount_per_fund
      @scenario.savings_accounts_by_interest_rate.each do |account|
        to_debit = [account.running_balance(month), current].min
        account.debit(month, to_debit)
        current -= to_debit
        break if current <= 0
      end
    end
  end

  def upcoming_expenses(month)
    current = month
    upcoming_expenses = 0
    6.times do
      [@scenario.expense_accounts, @scenario.home_equity_accounts].each do |bundle|
        bundle.each do |account|
          account.project(current)
          upcoming_expenses += account.amount(current)
        end
      end
      current = current.next
    end
    upcoming_expenses > 0 ? upcoming_expenses : 0
  end

  def mutual_fund_balance(month)
    @scenario.mutual_funds.reduce(0) { |a, e| a + e.starting_balance(month) }
  end

  def contribute_to_401ks(month, amount)
    amount_available_per_owner = amount / @scenario.income_accounts.length
    contribution_limit = @scenario.tax_info.annual_401k_contribution_limit_for_year(month.year)
    months_remaining = 12 - month.month + 1
    contributed = 0
    @scenario.income_accounts.each do |income_account|
      accounts = @scenario.active_401ks_by_owner(income_account.owner)
      next if accounts.empty?
      ytd_contributions = income_account.ytd_401k_contributions(month)
      allowable_contributions = contribution_limit - ytd_contributions
      next if allowable_contributions <= 0
      max_monthly_contribution = allowable_contributions / months_remaining
      to_contribute = ([max_monthly_contribution, amount_available_per_owner].min / accounts.length).round(2)
      accounts.each do |_401k|
        _401k.buy(month, to_contribute)
        income_account.record_pretax_401k_contribution(month, to_contribute) if _401k.is_a? Roth401k
        income_account.record_aftertax_401k_contribution(month, to_contribute) if _401k.is_a? Traditional401k
      end
      contributed += to_contribute * accounts.length
    end
    amount - contributed
  end

  def generate_report(month)
    accumulator = SummaryAccumulator.new
    [@scenario.income_accounts, @scenario.expense_accounts, @scenario.home_equity_accounts,
        @scenario.savings_accounts, @scenario.mutual_funds, @scenario.traditional401ks,
        @scenario.roth401ks].each do |bundle|
      bundle.each { |a| accumulator.merge(a.summary(month)) }
    end
    accumulator.summary
  end

end
