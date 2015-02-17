class MutualFund < ActiveRecord::Base

  belongs_to :scenario

  has_many :stock_activities, -> { order(:month) },
                              after_add: :build_transaction_from_activity

  serialize :starting_month, Month
  serialize :interest_rate, RandomVariable

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :starting_balance, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month < starting_month
    return if stock_activities.find { |a| a.month == month }
  end

  private

  def init
    @transactions = {}
  end

  def activities_must_be_in_sequence
    current_month = starting_month
    stock_activities.each do |activity|
      if activity.month != current_month
        errors.add(:stock_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

  def build_transaction_from_activity(activity)
  end

  def projections_start
    stock_activities.empty? ? starting_month : stock_activities.last.month.next
  end

end
