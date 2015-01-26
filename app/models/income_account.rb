class IncomeAccount < ActiveRecord::Base

  belongs_to :scenario

  has_many :monthly_overrides, as: :vector

  has_one :savings_account

  validates :name, presence: true
  validates :annual_gross, presence: true, numericality: true

  def project(month)
    raise "Cannot calculate amount for month prior to start month" if month < starting_month
    raise "Need at least one savings account to run income" unless savings_account
    override = monthly_overrides.find { |o| o.month == month }
    gross = override ? override.amount : annual_gross / 12.0
    transact(month, gross)
  end

  def gross(month)
    @transactions[month]
  end

  private

  def transact(month, gross)
    savings_account.credit(month, gross)
    @transactions ||= {}
    @transactions[month] ||= BigDecimal.new('0')
    @transactions[month] += gross
  end

end
