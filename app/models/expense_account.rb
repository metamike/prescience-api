class ExpenseAccount < ActiveRecord::Base

  belongs_to :scenario

  has_many :expense_account_activities, -> { order(:month) },
                                        after_add: :transactions_from_activity

  serialize :starting_month
  serialize :month_coefficents

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :starting_amount, presence: true, numericality: true
  validates :increase_schedule, inclusion: { in: %w(monthly yearly) }

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    raise "Cannot calculate amount for month prior to start month" if month < starting_month
    return @transactions[month] if @transactions[month]

    if year_matches(month.year) && month_matches(month.month)
      amount = (starting_amount * coefficients[month.month - 1]) * raise_coefficient(month)
    else
      amount = BigDecimal.new('0')
    end
    transact(month, amount)
    @transactions[month] = amount
  end

  def amount(month)
    @transactions[month]
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

  def raise_coefficient(month)
    if increase_schedule == 'monthly'
      (1 + rate_of_increase) ** (month - starting_month)
    else
      (1 + rate_of_increase) ** (month.year_diff(starting_month))
    end
  end

  def init
    @transactions = {}
    self.year_interval ||= 1
    self.rate_of_increase ||= 0
    self.increase_schedule ||= 'monthly'
    self.month_coefficients ||= 12.times.map { 1 }
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

  def transactions_from_activity(activity)
    @transactions[activity.month] = activity.amount
  end

  def transact(month, amount)
    savings_accounts = scenario.savings_accounts.sort_by(&:interest_rate)
    current = amount
    savings_accounts.each do |account|
      current = debit_account(account, month, current)
      break if current > 0
    end
    raise "Insufficient funds to debit #{amount} for #{name}" if current > 0
  end

  def debit_account(account, month, amount)
    if account.ending_balance(month.prior) >= amount
      account.debit(month, amount)
      0
    else
      remaining = amount - account.ending_balance(month.prior)
      account.debit(month, account.ending_balance(month.prior))
      remaining
    end
  end

end
