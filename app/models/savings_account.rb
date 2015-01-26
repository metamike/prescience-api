class SavingsAccount < ActiveRecord::Base
 
  belongs_to :scenario

  has_many :savings_account_activities, -> { order(:month) },
                                        after_add: :transactions_from_activity

  serialize :starting_month

  validates :interest_rate, presence: true, numericality: true
  validates :starting_month, presence: true

  validates :starting_balance, presence: true, numericality: true, if: ->(a) { a.savings_account_activities.empty? }

  after_initialize :init_transactions

  validate :activities_must_be_in_sequence

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

  def credit(month, amount)
    reset_month(month) unless @transactions[month]
    @transactions[month][:credits] += amount
  end

  def debit(month, amount)
    reset_month(month) unless @transactions[month]
    @transactions[month][:debits] += amount
  end

  def project(month)
    raise "Cannot project for month prior to starting month" if month < starting_month
    reset_month(month) unless @transactions[month]
    activity = savings_account_activities.find { |a| a.month == month }

    if activity
      # No work to be done here
    elsif month == starting_month
      @transactions[month][:interest] = calc_interest(starting_balance, @transactions[month])
      @transactions[month][:ending_balance] = starting_balance + @transactions[month][:interest]
    else
      prior_tx = @transactions[month.prior]
      raise "Could not find prior month's ending balance: #{month.prior}" unless prior_tx
      @transactions[month][:interest] = calc_interest(prior_tx[:ending_balance], @transactions[month])
      @transactions[month][:ending_balance] = prior_tx[:ending_balance] + @transactions[month][:interest]
    end
  end

  def interest(month)
    raise "Did not project this month" unless @transactions[month]
    @transactions[month][:interest]
  end

  def ending_balance(month)
    raise "Did not project this month" unless @transactions[month]
    @transactions[month][:ending_balance]
  end

  private

  def calc_interest(starting_balance, tracker)
    (starting_balance + tracker[:credits] - tracker[:debits]) * interest_rate
  end

  def init_transactions
    @transactions = {}
  end

  def reset_month(month)
    @transactions[month] = {
      credits: BigDecimal.new('0'),
      debits: BigDecimal.new('0'),
      interest: BigDecimal.new('0'),
      ending_balance: BigDecimal.new('0')
    }
  end

  def transactions_from_activity(activity)
    @transactions[activity.month] = {
      credits: BigDecimal.new('0'),
      debits: BigDecimal.new('0'),
      interest: activity.interest,
      ending_balance: activity.ending_balance
    }
  end

end
