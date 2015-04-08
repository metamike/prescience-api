class HomeEquityAccount < ActiveRecord::Base

  include Expendable

  belongs_to :scenario
  belongs_to :owner

  has_many :home_equity_account_activities, -> { order(:month) },
                                            after_add: :build_transaction_from_activity

  serialize :month_bought, Month

  validates :month_bought, presence: true
  validates :loan_amount, presence: true, numericality: true
  validates :loan_term_months, presence: true, numericality: true
  validates :interest_rate, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month < month_bought
    return if home_equity_account_activities.find { |a| a.month == month }

    interest = (starting_balance(month) * interest_rate / 12.0).round(2)
    principal = monthly_payment - interest
    principal = starting_balance(month) if principal > starting_balance(month)
    ending_balance = starting_balance(month) - principal
    @transactions[month] = {principal: principal, interest: interest, ending_balance: ending_balance}
  end

  def transact(month)
    raise "No projection for #{month}. Please run #project first" unless @transactions[month]
    expense(month, amount(month))
  end

  def principal(month)
    @transactions[month] ? @transactions[month][:principal] : 0
  end

  def interest(month)
    @transactions[month] ? @transactions[month][:interest] : 0
  end

  def amount(month)
    principal(month) + interest(month)
  end

  def starting_balance(month)
    month == month_bought ? loan_amount : (@transactions[month.prior] ? @transactions[month.prior][:ending_balance] : 0)
  end

  def ending_balance(month)
    @transactions[month] ? @transactions[month][:ending_balance] : 0
  end

  def almost_paid_off?(month)
    starting_balance(month) < loan_amount / 3   # Last ~7 years
  end

  def summary(month)
    {
      'home equity' => {
        'starting balance' => starting_balance(month),
        'principal' => principal(month),
        'interest' => interest(month),
        'ending balance' => ending_balance(month)
      }
    }
  end

  private

  def init
    @transactions = {}
    home_equity_account_activities.sort_by(&:month).each { |a| build_transaction_from_activity(a) }
  end

  def activities_must_be_in_sequence
    current_month = month_bought
    home_equity_account_activities.sort_by(&:month).each do |activity|
      if activity.month != current_month
        errors.add(:home_equity_account_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

  def build_transaction_from_activity(activity)
    @transactions[activity.month] = {
      principal: activity.principal,
      interest: activity.interest,
      ending_balance: starting_balance(activity.month) - activity.principal
    }
  end

  def monthly_payment
    period_rate = interest_rate / 12.0
    @monthly_payment ||= (loan_amount * (period_rate * (1 + period_rate) ** loan_term_months) /
      ((1 + period_rate) ** loan_term_months - 1)).round(2)
  end

end
