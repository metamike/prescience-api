class HomeEquityAccountActivity < ActiveRecord::Base

  belongs_to :home_equity_account

  serialize :month, Month

  validates :month, presence: true
  validates :principal, presence: true, numericality: true
  validates :interest,  presence: true, numericality: true

end
