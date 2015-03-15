class ExpenseAccount < ActiveRecord::Base

  belongs_to :scenario

  has_many :expense_account_activities, -> { order(:month) },
                                        after_add: :build_transaction_from_activity

  serialize :starting_month, Month
  serialize :month_coefficents
  serialize :rate_of_increase, RandomVariable

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :starting_amount, presence: true, numericality: true
  validates :stdev_coefficient, numericality: true
  validates :increase_schedule, inclusion: { in: %w(monthly yearly) }

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month < starting_month
    return if expense_account_activities.find { |a| a.month == month }

    raise_coefficient(month)
    if year_matches(month.year) && month_matches(month.month)
      amount = (month_base(month) * raise_coefficient(month)).round(2)
    else
      amount = BigDecimal.new('0')
    end
    @transactions[month] = amount
  end

  def transact(month)
    raise "No projection for #{month}. Please run #project first" unless @transactions[month]
    savings_accounts = scenario.savings_accounts_by_interest_rate
    current = @transactions[month]
    savings_accounts.each do |account|
      current = debit_account(account, month, current)
      break if current <= 0
    end
    raise "Insufficient funds to debit #{@transactions[month]} for #{name}" if current > 0
  end

  def summary(month)
    {
      'expenses' => {
        name => {
          'amount' => amount(month)
        },
        'TOTAL' => {
          'amount' => amount(month)
        }
      }
    }
  end

  def amount(month)
    @transactions.has_key?(month) ? @transactions[month] : BigDecimal.new('0')
  end

  def coefficients
    YAML.load(month_coefficients)
  end

  private

  def year_matches(year)
    (year - starting_month.year) % year_interval == 0
  end

  def month_matches(month)
    coefficients[month - 1] != 0
  end

  def month_base(month)
    amount = coefficients[month.month - 1] * starting_amount
    RandomVariable.new(amount, amount * stdev_coefficient).sample
  end

  def raise_coefficient(month)
    if increase_schedule == 'monthly'
      return @rates_of_increase[month] if @rates_of_increase[month]
      if month == projections_start
        @rates_of_increase[month] = 1
      else
        @rates_of_increase[month] = (1 + rate_of_increase.sample) * (@rates_of_increase[month.prior] || 1)
      end
    else
      return @rates_of_increase[month.year] if @rates_of_increase[month.year]
      if month.year == projections_start.year
        @rates_of_increase[month.year] = 1
      else
        @rates_of_increase[month.year] = (1 + rate_of_increase.sample) * (@rates_of_increase[month.prior_year] || 1)
      end
    end
  end

  def init
    @transactions = {}
    @rates_of_increase = {}
    self.year_interval ||= 1
    self.rate_of_increase ||= RandomVariable.new(0)
    self.increase_schedule ||= 'monthly'
    self.month_coefficients ||= 12.times.map { 1 }
    self.stdev_coefficient ||= 0
    expense_account_activities.each { |a| build_transaction_from_activity(a) }
  end

  def activities_must_be_in_sequence
    current_month = starting_month
    expense_account_activities.each do |activity|
      if activity.month != current_month
        errors.add(:expense_account_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

  def build_transaction_from_activity(activity)
    @transactions[activity.month] = activity.amount
  end

  def projections_start
    expense_account_activities.empty? ? starting_month : expense_account_activities.last.month.next
  end

  def debit_account(account, month, amount)
    starting_balance = account.start_balance(month)
    if starting_balance >= amount
      account.debit(month, amount)
      0
    else
      remaining = amount - starting_balance
      account.debit(month, starting_balance)
      remaining
    end
  end

end
