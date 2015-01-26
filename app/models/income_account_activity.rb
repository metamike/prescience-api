class IncomeAccountActivity < ActiveRecord::Base

  belongs_to :income_account

  serialize :month

  validates :month, presence: true
  validates :gross, presence: true, numericality: true

end
