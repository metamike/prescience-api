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

  def ending_balance(month)
    @cohorts.ending_balance(month)
  end

  private

  def init
    @transactions = {}
    @cohorts = CohortMatrix.new
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
