class TaxBracket < ActiveRecord::Base

  belongs_to :historical_tax_info

  validates :type, presence: true, inclusion: %w(federal state)
  validates :filing_status, presence: true, inclusion: %w(single married)
  validates :lower_bound, presence: true, numericality: true
  validates :slope, presence: true, numericality: true
  validates :intercept, presence: true, numericality: true

  def tax(income)
    (income * slope + intercept).round(2)
  end

end
