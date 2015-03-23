class StockBundle < ActiveRecord::Base

  belongs_to :investment_account

  has_many :stock_activities, -> { order(:month) }

  serialize :month_bought, Month

  validates :month_bought, presence: true
  validates :amount, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  private

  def activities_must_be_in_sequence
    current_month = month_bought
    stock_activities.each do |activity|
      if activity.month != current_month
        errors.add(:stock_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

end
