class StockActivity < ActiveRecord::Base

  belongs_to :mutual_fund

  serialize :month, Month

  validates :month, presence: true
  validates :bought, numericality: true
  validates :sold, numericality: true
  validates :performance, presence: true, numericality: true
  validates :dividends, numericality: true

end
