class IncomeAccount < ActiveRecord::Base

  belongs_to :scenario

  has_one :savings_account

  has_many :income_account_activities, -> { order(:month) },
                                       after_add: :build_transaction_from_activity

  serialize :starting_month, Month
  serialize :annual_raise, RandomVariable

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :annual_salary, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month < starting_month
    raise "Need at least one savings account to run income" unless savings_account
    gross = @transactions[month] || (calc_gross(month) / 12.0).round(2)
    transact(month, gross)
  end

  def gross(month)
    @transactions[month] || 0
  end

  def salary(month)
    @annual_salaries[month.year] || 0
  end

  def raise(month)
    @annual_raises[month.year] || 0
  end

  private

  def init
    @transactions = {}
    @annual_raises = {}
    @annual_salaries = {}
    self.annual_raise ||= RandomVariable.new(0)
  end

  def activities_must_be_in_sequence
    current_month = starting_month
    income_account_activities.each do |activity|
      if activity.month != current_month
        errors.add(:income_account_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

  def build_transaction_from_activity(activity)
    @transactions[activity.month] = activity.gross
  end

  def calc_gross(month)
    return @annual_salaries[month.year] if @annual_salaries[month.year]
    annual_raise = calc_raise(month.year)
    prior_salary = @annual_salaries[month.prior_year] || annual_salary
    @annual_salaries[month.year] = prior_salary * (1 + annual_raise)
  end

  def calc_raise(year)
    return 0 if year <= projections_start.year
    @annual_raises[year] ||= annual_raise.sample
  end

  def projections_start
    income_account_activities.empty? ? starting_month : income_account_activities.last.month.next
  end

  def transact(month, gross)
    savings_account.credit(month, gross)
    @transactions[month] = gross
  end

end
