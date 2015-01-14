class SavingsAccount < ActiveRecord::Base

  belongs_to :scenario

  has_many :monthly_overrides, as: :vector

  monetize :starting_balance_cents

  serialize :starting_month

  validates :interest_rate, presence: true
  validates :starting_balance, numericality: true, presence: true
  validates :starting_month, presence: true

  def calc(month)
    override = overrides.find { |o| o.month == month }
    return override if override

    balance = starting_balance
    starting_month.upto(month) do |_month|
      balance *= (1 + interest_rate)
    end
    balance
  end

end
