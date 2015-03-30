class CohortMatrix

  def initialize
    @cohorts = {}
    @ending_balance_cache = {}
  end

  def each_cohort
    # Need to dupe to allow inserts while iterating
    @cohorts.dup.each do |cohort_month, cohort|
      yield cohort_month, cohort
    end
  end

  def cohort_ending_balance(cohort_month, month)
    return 0 unless @cohorts[cohort_month] && @cohorts[cohort_month][month]
    @ending_balance_cache[cohort_month] ||= {}
    return @ending_balance_cache[cohort_month][month] if @ending_balance_cache[cohort_month][month]

    cohort = @cohorts[cohort_month][month]
    if month == cohort_month
      balance = (cohort[:bought] || 0) + (cohort[:performance] || 0) + (cohort[:dividends] || 0) - (cohort[:sold] || 0)
      @ending_balance_cache[cohort_month][month] = balance
    else
      balance = (cohort[:bought] || 0) + (cohort[:performance] || 0) - (cohort[:sold] || 0)
      @ending_balance_cache[cohort_month][month] = balance + cohort_ending_balance(cohort_month, month.prior)
    end
  end

  def cohort_starting_balance(cohort_month, month)
    month == cohort_month ? (@cohorts[cohort_month][month][:bought] || 0) : cohort_ending_balance(cohort_month, month.prior)
  end

  def ending_balance(month)
    @cohorts.keys.reduce(0) { |a, c| a += cohort_ending_balance(c, month) }
  end

  def starting_balance(month)
    ending_balance(month.prior)
  end

  def performance(month)
    @cohorts.keys.reduce(0) { |a, c|
      a += @cohorts[c][month] ? @cohorts[c][month][:performance] : 0
    }
  end

  def taxable_dividends(month)
    @cohorts.keys.reduce(0) { |a, c|
      a += (@cohorts[c][month] && month - c <= 12) ? @cohorts[c][month][:dividends] : 0
    }
  end

  def qualified_dividends(month)
    @cohorts.keys.reduce(0) { |a, c|
      a += (@cohorts[c][month] && month - c > 12) ? @cohorts[c][month][:dividends] : 0
    }
  end

  def total_performance(month)
    performance(month) + taxable_dividends(month) + qualified_dividends(month)
  end

  def bought(month)
    @cohorts.keys.reduce(0) { |a, c|
      a += @cohorts[c][month] ? @cohorts[c][month][:bought] : 0
    }
  end

  def sold(month)
    @cohorts.keys.reduce(0) { |a, c|
      a += @cohorts[c][month] ? @cohorts[c][month][:sold] : 0
    }
  end

  def short_term_net(year)
    net = 0
    Month.new(year, 1).upto(Month.new(year, 12)) do |month|
      @cohorts.each do |cohort_month, cohort|
        if month - cohort_month <= 12 && cohort[month] && cohort[month][:sold] && cohort[month][:sold] > 0
          net += cohort[month][:capital_net]
        end
      end
    end
    net
  end

  def long_term_net(year)
    net = 0
    Month.new(year, 1).upto(Month.new(year, 12)) do |month|
      @cohorts.each do |cohort_month, cohort|
        if month - cohort_month > 12 && cohort[month] && cohort[month][:sold] && cohort[month][:sold] > 0
          net += cohort[month][:capital_net]
        end
      end
    end
    net
  end

  def record_buy(month, amount)
    @ending_balance_cache = {}
    @cohorts[month] ||= {}
    init_month(month, month) unless @cohorts[month][month]
    @cohorts[month][month][:bought] += amount
  end

  def record_performance(cohort_month, month, amount)
    raise "Invalid month #{month} for cohort #{cohort_month}" if month < cohort_month
    @ending_balance_cache = {}
    init_month(cohort_month, month) unless @cohorts[cohort_month][month]
    @cohorts[cohort_month][month][:performance] += amount
  end

  def record_dividends(cohort_month, month, amount, create_new_cohort = true)
    raise "Invalid month #{month} for cohort #{cohort_month}" if month < cohort_month
    @ending_balance_cache = {}
    init_month(cohort_month, month) unless @cohorts[cohort_month][month]
    @cohorts[cohort_month][month][:dividends] += amount
    record_buy(month, amount) if create_new_cohort && amount > 0
  end

  def optimal_sell(month, amount)
    raise "Insufficient funds to sell #{amount} on #{month}" if amount > ending_balance(month.prior)
    current = amount
    @cohorts.keys.sort.each do |cohort_month|
      starting_balance = cohort_starting_balance(cohort_month, month)
      if starting_balance > 0
        to_sell = current > starting_balance ? starting_balance : current
        record_sell(cohort_month, month, to_sell)
        current -= to_sell
        break if current <= 0
      end
    end
  end

  def record_sell(cohort_month, month, amount)
    raise "Invalid month #{month} for cohort #{cohort_month}" if month < cohort_month
    @ending_balance_cache = {}
    init_month(cohort_month, month) unless @cohorts[cohort_month][month]
    @cohorts[cohort_month][month][:sold] += amount
    # N = O - S / (B/O) ---> O(1 - S/B)
    @cohorts[cohort_month][month][:ending_shares] = cohort_starting_shares(cohort_month, month) * (1 - @cohorts[cohort_month][month][:sold] / cohort_starting_balance(cohort_month, month))
    @cohorts[cohort_month][month][:shares_sold] = cohort_starting_shares(cohort_month, month) - @cohorts[cohort_month][month][:ending_shares]
    @cohorts[cohort_month][month][:capital_net] = (@cohorts[cohort_month][month][:sold] - @cohorts[cohort_month][month][:shares_sold]).round(2)
  end

  private

  def init_month(cohort_month, month)
    @cohorts[cohort_month][month] = {bought: 0, sold: 0, performance: 0, dividends: 0}
  end

  def cohort_starting_shares(cohort_month, month)
    if cohort_month == month
      @cohorts[cohort_month][month][:bought]
    else
      @cohorts[cohort_month][month.prior][:ending_shares] || cohort_starting_shares(cohort_month, month.prior)
    end
  end

end
