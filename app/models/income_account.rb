class IncomeAccount < ActiveRecord::Base

  belongs_to :scenario
  belongs_to :owner

  has_many :income_account_activities, -> { order(:month) },
                                       after_add: :build_transaction_from_activity

  serialize :starting_month, Month
  serialize :annual_raise, RandomVariable

  validates :owner, presence: true
  validates :name, presence: true
  validates :starting_month, presence: true
  validates :annual_salary, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month < starting_month
    @transactions[month] ||= (calc_gross(month) / 12.0).round(2)
  end

  def gross(month)
    @transactions[month] || 0
  end

  def salary(month)
    @annual_salaries[month.year] || 0
  end

  def transact(month)
    raise "No income projected for #{month.to_s}" unless @transactions[month]
    savings_account = scenario.savings_account_by_owner(owner)
    raise "No savings account found for #{owner.name}" unless savings_account
    savings_account.credit(month, @transactions[month])
  end

  private

  def init
    @transactions = {}
    @annual_raises = {}
    @annual_salaries = {}
    self.annual_raise ||= RandomVariable.new(0)
    income_account_activities.each { |a| build_transaction_from_activity(a) }
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

end
