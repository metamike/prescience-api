class HistoricalTaxInfo < ActiveRecord::Base

  belongs_to :tax_info

  validates :year, presence: true, numericality: true

  validates :social_security_wage_limit, presence: true, numericality: true
  validates :state_disability_wage_limit, presence: true, numericality: true
  validates :annual_401k_contribution_limit, presence: true, numericality: true
  validates :standard_deduction, presence: true, numericality: true
  validates :max_capital_loss, presence: true, numericality: true

  validates :personal_exemption_income_limit_single, presence: true, numericality: true
  validates :personal_exemption_income_limit_married, presence: true, numericality: true
  validates :personal_exemption, presence: true, numericality: true

end
