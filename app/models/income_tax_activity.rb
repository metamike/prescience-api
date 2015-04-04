class IncomeTaxActivity < ActiveRecord::Base

  belongs_to :income_tax_account

  validates :year, presence: true, numericality: {only_integer: true}
  validates :filing_status, presence: true, inclusion: %w(single married)

  # Income
  validates :wages, presence: true, numericality: true, allow_nil: true
  validates :taxable_interest, numericality: true, allow_nil: true
  validates :taxable_dividends, numericality: true, allow_nil: true
  validates :qualified_dividends, numericality: true, allow_nil: true
  validates :short_term_capital_net, numericality: true, allow_nil: true
  validates :long_term_capital_net, numericality: true, allow_nil: true

  # Outputs
  validates :adjusted_gross_income, presence: true, numericality: true
  validates :taxable_income, presence: true, numericality: true
  validates :federal_itemized_deductions, presence: true, numericality: true
  validates :federal_income_tax, presence: true, numericality: true
  validates :federal_income_tax_owed, presence: true, numericality: true
  validates :state_income_tax, presence: true, numericality: true
  validates :state_income_tax_owed, presence: true, numericality: true

end
