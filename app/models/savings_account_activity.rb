class SavingsAccountActivity < ActiveRecord::Base

  belongs_to :savings_account

  serialize :month

  validates :month, presence: true
  validates :interest, presence: true, numericality: true
  validates :ending_balance, presence: true, numericality: true

end
