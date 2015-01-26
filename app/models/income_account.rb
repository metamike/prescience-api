class IncomeAccount < ActiveRecord::Base

  belongs_to :scenario

  has_one :savings_account

  has_many :income_account_activities, -> { order(:month) },
                                       after_add: :transactions_from_activity

  serialize :starting_month

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :annual_gross, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init_transactions

  def project(month)
    raise "Cannot calculate amount for month prior to start month" if month < starting_month
    raise "Need at least one savings account to run income" unless savings_account
    gross = @transactions[month] || annual_gross / 12.0
    transact(month, gross)
  end

  def gross(month)
    @transactions[month]
  end

  private

  def init_transactions
    @transactions = {}
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

  def transactions_from_activity(activity)
    @transactions[activity.month] = activity.gross
  end

  def transact(month, gross)
    savings_account.credit(month, gross)
    @transactions[month] = gross
  end

end
