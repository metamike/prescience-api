class Scenario < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_many :savings_accounts
  has_many :income_accounts
  has_many :expense_accounts
  has_many :mutual_funds

  serialize :projections_start, Month

  validates :projections_start, presence: true

  def savings_account_by_owner(owner)
    savings_accounts.find { |a| a.owner == owner }
  end

end
