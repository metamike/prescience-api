class MutualFund < ActiveRecord::Base

  belongs_to :scenario

  has_many :stock_bundles

  serialize :starting_month, Month
  serialize :monthly_interest_rate, RandomVariable
  serialize :monthly_dividend_rate, RandomVariable

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :monthly_interest_rate, presence: true

  after_initialize :init

  def project(month)
    return if month < starting_month
    return if @transactions.has_key?(month)

    @transactions[month] = {
      taxable_performance: 0, qualified_performance: 0,
      taxable_dividends: 0,   qualified_dividends: 0,
      ending_balance: 0
    }
    prior_balance = @transactions[month.prior] ? @transactions[month.prior][:ending_balance] : 0
    stock_bundles.each do |bundle|
      if bundle.month_bought == month
        @transactions[month][:ending_balance] += bundle.amount
      end
      activity = bundle.stock_activities.find { |a| a.month == month }
      if activity
        if activity.month - bundle.month_bought <= 12
          @transactions[month][:taxable_performance] += activity.performance
        else
          @transactions[month][:qualfied_performance] += activity.performance
        end
        @transactions[month][:ending_balance] += activity.performance
      end
    end
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

end
