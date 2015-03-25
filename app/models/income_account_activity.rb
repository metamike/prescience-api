class IncomeAccountActivity < ActiveRecord::Base

  belongs_to :income_account

  serialize :month, Month

  validates :month,                presence: true

  validates :gross,                presence: true, numericality: true
  validates :federal_income_tax,   presence: true, numericality: true
  validates :social_security_tax,  presence: true, numericality: true
  validates :medicare_tax,         presence: true, numericality: true
  validates :state_income_tax,     presence: true, numericality: true
  validates :state_disability_tax, presence: true, numericality: true
  validates :net,                  presence: true, numericality: true

  validates :pretax_401k_contribution,   numericality: true
  validates :aftertax_401k_contribution, numericality: true

end
