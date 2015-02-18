class StockActivity < ActiveRecord::Base

  belongs_to :stock_bundle

  serialize :month, Month

  validates :month, presence: true
  validates :sold, numericality: true
  validates :performance, presence: true, numericality: true
  validates :dividends, numericality: true

  after_initialize :init

  private

  def init
    self.sold ||= 0
    self.dividends ||= 0
  end

end
