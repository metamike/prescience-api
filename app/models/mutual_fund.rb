class MutualFund < ActiveRecord::Base

  belongs_to :scenario

  has_many :stock_bundles, after_add: :record_transactions_from_bundle

  serialize :starting_month, Month
  serialize :monthly_interest_rate, RandomVariable
  serialize :quarterly_dividend_rate, RandomVariable

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :monthly_interest_rate, presence: true

  after_initialize :init

  def project(month)
    return if month < starting_month
    interest_rate = monthly_interest_rate.sample
    @interest_rates[month] = interest_rate
    dividend_rate = quarterly_dividend_rate.sample if month.end_of_quarter?
    @dividend_rates[month] = dividend_rate
    @cohorts.each_cohort do |cohort_month, cohort|
      next if cohort[month]
      starting_balance = @cohorts.cohort_ending_balance(cohort_month, month.prior)
      next if starting_balance == 0
      @cohorts.record_performance(cohort_month, month, (interest_rate * starting_balance).round(2))
      if month.end_of_quarter?
        @cohorts.record_dividends(cohort_month, month, (dividend_rate * starting_balance).round(2))
      end
    end
  end

  def bought(month)
    @cohorts.bought(month)
  end

  def sold(month)
    @cohorts.bought(month)
  end

  def taxable_performance(month)
    @cohorts.taxable_performance(month)
  end

  def qualified_performance(month)
    @cohorts.qualified_performance(month)
  end

  def taxable_dividends(month)
    @cohorts.taxable_dividends(month)
  end

  def qualified_dividends(month)
    @cohorts.qualified_dividends(month)
  end

  def total_performance(month)
    @cohorts.total_performance(month)
  end

  def ending_balance(month)
    @cohorts.ending_balance(month)
  end

  def interest_rate(month)
    @interest_rates[month] || 0
  end

  def dividend_rate(month)
    @dividend_rates[month] || 0
  end

  private

  def init
    @transactions = {}
    @cohorts = CohortMatrix.new
    @interest_rates = {}
    @dividend_rates = {}
    stock_bundles.each { |b| record_transactions_from_bundle(b) }
  end

  def record_transactions_from_bundle(bundle)
    record_stock_purchase(bundle)
    bundle.stock_activities.sort_by(&:month).each do |activity|
      record_stock_activity(activity)
    end
  end

  def record_stock_purchase(bundle)
    @cohorts.record_buy(bundle.month_bought, bundle.amount)
  end

  def record_stock_activity(activity)
    @cohorts.record_performance(activity.stock_bundle.month_bought, activity.month, activity.performance)
    @cohorts.record_dividends(activity.stock_bundle.month_bought, activity.month, activity.dividends, false)
    @cohorts.record_sell(activity.stock_bundle.month_bought, activity.month, activity.sold)
  end

end
