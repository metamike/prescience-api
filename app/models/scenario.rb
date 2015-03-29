class Scenario < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_one :tax_info

  has_many :savings_accounts
  has_many :income_accounts
  has_many :expense_accounts
  has_many :mutual_funds
  has_many :traditional401ks
  has_many :roth401ks
  has_many :home_equity_accounts

  serialize :starting_month,    Month
  serialize :projections_start, Month

  validates :starting_month,    presence: true
  validates :projections_start, presence: true

  validate :one_401k_per_owner

  def savings_account_by_owner(owner)
    savings_accounts.find { |a| a.owner == owner }
  end

  def savings_accounts_by_interest_rate
    savings_accounts.sort_by(&:monthly_interest_rate)
  end

  def active_401ks_by_owner(owner)
    [traditional401ks, roth401ks].map { |bundle| bundle.find { |a| a.owner == owner && a.active? }  }.compact
  end

  def commuter_account_by_owner(owner)
    expense_accounts.find { |a| a.owner == owner && a.name == 'Commuter' }
  end

  private

  def one_401k_per_owner
    active = traditional401ks.select { |a| a.active? }.map(&:owner_id)
    errors.add(:traditional401ks, "Only one active traditional 401(k) is allowed per owner") if active.length != active.uniq.length
    active = roth401ks.select { |a| a.active? }.map(&:owner_id)
    errors.add(:roth401ks, "Only one active roth 401(k) is allowed per owner") if active.length != active.uniq.length
  end

end
