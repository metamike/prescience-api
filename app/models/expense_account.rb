class ExpenseAccount < ActiveRecord::Base

  belongs_to :scenario

  has_many :expense_account_activities, -> { order(:month) },
                                        after_add: :transactions_from_activity

  serialize :starting_month
  serialize :month_coefficents

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :starting_amount, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init_transactions

  private

  def init_transactions
    @transactions = {}
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

end
