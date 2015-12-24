class HistoricalTaxInfo < ActiveRecord::Base

  belongs_to :tax_info

  has_many :tax_brackets

  validates :year, presence: true, numericality: true

  validates :social_security_wage_limit, presence: true, numericality: true
  validates :state_disability_wage_limit, presence: true, numericality: true
  validates :annual_401k_contribution_limit, presence: true, numericality: true
  validates :standard_deduction, presence: true, numericality: true
  validates :max_capital_loss, presence: true, numericality: true

  validates :personal_exemption_income_limit_single, presence: true, numericality: true
  validates :personal_exemption_income_limit_married, presence: true, numericality: true
  validates :personal_exemption, presence: true, numericality: true

  def federal_tax(filing_status, income)
    calculate_tax('federal', filing_status, income)
  end

  def state_tax(filing_status, income)
    calculate_tax('state', filing_status, income)
  end

  private

  def calculate_tax(type, filing_status, income)
    bracket = tax_brackets.select { |b| b.type == type && b.filing_status == filing_status }
                          .sort_by(&:lower_bound)
                          .reverse
                          .find { |b| income >= b.lower_bound }
    bracket.tax(income)
  end

end
