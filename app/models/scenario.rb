class Scenario < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_many :savings_accounts
  has_many :income_accounts
  has_many :expense_accounts
  has_many :mutual_funds
  has_many :home_equity_accounts

  serialize :starting_month,    Month
  serialize :projections_start, Month

  validates :starting_month,    presence: true
  validates :projections_start, presence: true

  def savings_account_by_owner(owner)
    savings_accounts.find { |a| a.owner == owner }
  end

  def savings_accounts_by_interest_rate
    savings_accounts.sort_by(&:monthly_interest_rate)
  end

end
