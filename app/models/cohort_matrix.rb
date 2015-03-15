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

  def ending_balance(month)
    @cohorts.keys.reduce(0) { |a, c| a += cohort_ending_balance(c, month) }
  end

  def starting_balance(month)
    ending_balance(month.prior)
  end

  def taxable_performance(month)
    @cohorts.keys.reduce(0) { |a, c|
      a += (@cohorts[c][month] && month - c <= 12) ? @cohorts[c][month][:performance] : 0
    }
  end

  def qualified_performance(month)
    @cohorts.keys.reduce(0) { |a, c|
      a += (@cohorts[c][month] && month - c > 12) ? @cohorts[c][month][:performance] : 0
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
    taxable_performance(month) + qualified_performance(month) + taxable_dividends(month) + qualified_dividends(month)
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
      starting_balance = cohort_ending_balance(cohort_month, month.prior)
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
  end

  private

  def init_month(cohort_month, month)
    @cohorts[cohort_month][month] = {bought: 0, sold: 0, performance: 0, dividends: 0}
  end

end
