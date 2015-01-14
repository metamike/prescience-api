class MonthlyOverride < ActiveRecord::Base

  belongs_to :vector, polymorphic: true

  monetize :amount_cents
  serialize :month

  validates :month, presence: true
  validates :amount, presence: true, numericality: true

end
