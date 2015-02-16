class SavingsAccount < ActiveRecord::Base
 
  belongs_to :scenario

  has_many :savings_account_activities, -> { order(:month) },
                                        after_add: :build_transaction_from_activity

  serialize :starting_month, Month
  serialize :monthly_interest_rate, RandomVariable

  validates :starting_month, presence: true
  validates :monthly_interest_rate, presence: true

  validates :starting_balance, presence: true, numericality: true, if: ->(a) { a.savings_account_activities.empty? }

  after_initialize :init

  validate :activities_must_be_in_sequence

  def credit(month, amount)
    reset_month(month) unless @transactions[month]
    @transactions[month][:credits] += amount
  end

  def debit(month, amount)
    reset_month(month) unless @transactions[month]
    @transactions[month][:debits] += amount
  end

  def project(month)
    return if month < starting_month
    reset_month(month) unless @transactions[month]
    activity = savings_account_activities.find { |a| a.month == month }

    unless activity
      starting_balance = month == starting_month ? self.starting_balance : @transactions[month.prior][:ending_balance]
      @transactions[month][:interest] = calc_interest(starting_balance, month, @transactions[month][:credits], @transactions[month][:debits])
      @transactions[month][:ending_balance] = calc_balance(starting_balance, month, @transactions[month][:credits], @transactions[month][:debits])
    end
  end

  def interest(month)
    @transactions[month] ? @transactions[month][:interest] : 0
  end

  def ending_balance(month)
    @transactions[month] ? @transactions[month][:ending_balance] : 0
  end

  private

  def init
    @transactions = {}
    @monthly_interest_rates = {}
  end

  def activities_must_be_in_sequence
    current_month = starting_month
    savings_account_activities.each do |activity|
      if activity.month != current_month
        errors.add(:savings_account_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

  def build_transaction_from_activity(activity)
    @transactions[activity.month] = {
      credits: BigDecimal.new('0'),
      debits: BigDecimal.new('0'),
      interest: activity.interest,
      ending_balance: activity.ending_balance
    }
  end

  def calc_interest_rate(month)
    return @monthly_interest_rates[month] if @monthly_interest_rates[month]
    sampled = monthly_interest_rate.sample
    @monthly_interest_rates[month] = sampled >= 0 ? sampled : 0
  end

  def calc_interest(starting_balance, month, credits, debits)
    ((starting_balance + credits - debits) * calc_interest_rate(month)).round(2)
  end

  def calc_balance(starting_balance, month, credits, debits)
    starting_balance + credits - debits + calc_interest(starting_balance, month, credits, debits)
  end

  def reset_month(month)
    @transactions[month] = {
      credits: BigDecimal.new('0'),
      debits: BigDecimal.new('0'),
      interest: BigDecimal.new('0'),
      ending_balance: BigDecimal.new('0')
    }
  end

end
