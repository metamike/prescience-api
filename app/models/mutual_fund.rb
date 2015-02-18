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
  end

  def taxable_performance(month)
  end

  def qualified_performance(month)
  end

  def taxable_dividends(month)
  end

  def qualified_dividends(month)
  end

  def ending_balance(month)
  end

  private

  def init
  end

end
