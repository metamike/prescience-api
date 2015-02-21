class MutualFund < ActiveRecord::Base

  belongs_to :scenario

  has_many :stock_bundles, after_add: :record_transactions_from_bundle

  serialize :starting_month, Month
  serialize :monthly_interest_rate, RandomVariable
  serialize :monthly_dividend_rate, RandomVariable

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :monthly_interest_rate, presence: true

  after_initialize :init

  def project(month)
    return if month < starting_month
  end

  def taxable_performance(month)
    @transactions[month] ? @transactions[month][:taxable_performance] : 0
  end

  def qualified_performance(month)
    @transactions[month] ? @transactions[month][:qualified_performance] : 0
  end

  def taxable_dividends(month)
    @transactions[month] ? @transactions[month][:taxable_dividends] : 0
  end

  def qualified_dividends(month)
    @transactions[month] ? @transactions[month][:qualified_dividends] : 0
  end

  def ending_balance(month)
    @transactions[month] ? @transactions[month][:ending_balance] : 0
  end

  private

  def init
    @transactions = {}
  end

  def record_transactions_from_bundle(bundle)
    record_stock_purchase(bundle)
    bundle.stock_activities.sort_by(&:month).each do |activity|
      record_stock_activity(activity)
    end
  end

  def record_stock_purchase(bundle)
    reset_transaction(bundle.month_bought) unless @transactions[bundle.month_bought]
    @transactions[bundle.month_bought][:bought] += bundle.amount
  end

  def record_stock_activity(activity)
    reset_transaction(activity.month) unless @transactions[activity.month]
    if activity.month - activity.stock_bundle.month_bought <= 12
      @transactions[activity.month][:taxable_performance] += activity.performance
      @transactions[activity.month][:taxable_dividends] += activity.dividends
    else
      @transactions[activity.month][:qualified_performance] += activity.performance
      @transactions[activity.month][:qualified_dividends] += activity.dividends
    end
    @transactions[activity.month][:sold] += activity.sold

    prior_balance = @transactions[activity.month.prior] ? @transactions[activity.month.prior][:ending_balance] : 0
    @transactions[activity.month][:ending_balance] = prior_balance + total_performance(activity.month)
  end

  def total_performance(month)
    [:bought, :taxable_performance, :qualified_performance, :taxable_dividends, :qualified_dividends].reduce(0) { |a, e| a += @transactions[month][e] } - @transactions[month][:sold]
  end

  def reset_transaction(month)
    @transactions[month] = {
      bought: 0,              sold: 0,
      taxable_performance: 0, qualified_performance: 0,
      taxable_dividends: 0,   qualified_dividends: 0,
      ending_balance: 0
    }
  end

end
