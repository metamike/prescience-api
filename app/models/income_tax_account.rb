class IncomeTaxAccount < ActiveRecord::Base

  include Expendable

  TAX_MONTH = 4

  belongs_to :scenario
  belongs_to :owner

  has_many :income_tax_activities, -> { order(:year) },
                                   after_add: :build_transaction_from_activity

  validates :filing_status, presence: true, inclusion: %w(single married)
  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month.month != TAX_MONTH || @transactions[tax_year(month)]
    TaxFormBuilder.form_set.run(self, tax_year(month))
    @transactions[tax_year(month)] = {}
    @transactions[tax_year(month)][:federal_income_taxes] = -TaxFormBuilder.form_set.f1040.federal_income_tax_refund
    @transactions[tax_year(month)][:state_income_taxes] = -TaxFormBuilder.form_set.ca540.state_income_tax_refund
  end

  def transact(month)
    return unless month.month == TAX_MONTH
    raise "No projection for #{month}. Please run #project first" unless @transactions[tax_year(month)]
    expense(month, @transactions[tax_year(month)][:federal_income_taxes] +
                   @transactions[tax_year(month)][:state_income_taxes])
  end

  def federal_income_taxes(month)
    month.month == TAX_MONTH && @transactions[tax_year(month)] ? @transactions[tax_year(month)][:federal_income_taxes] : 0
  end

  def state_income_taxes(month)
    month.month == TAX_MONTH && @transactions[tax_year(month)] ? @transactions[tax_year(month)][:state_income_taxes] : 0
  end

  def summary(month)
    {
      'income taxes' => {
        'federal income taxes' => federal_income_taxes(month),
        'state income taxes' => state_income_taxes(month)
      }
    }
  end

  private

  def init
    @transactions = {}
    income_tax_activities.each { |a| build_transaction_from_activity(a) }
  end

  def activities_must_be_in_sequence
    current_year = nil
    income_tax_activities.sort_by(&:year).each do |activity|
      current_year ||= activity.year
      if activity.year != current_year
        errors.add(:income_tax_activities, "activity #{activity.year} is out of sequence")
        break
      end
      current_year += 1
    end
  end

  def build_transaction_from_activity(activity)
    @transactions[activity.year] = {}
    @transactions[activity.year][:federal_income_taxes] = -activity.federal_income_tax_refund
    @transactions[activity.year][:state_income_taxes] = -activity.state_income_tax_refund
  end

  def tax_year(month)
    month.year - 1
  end

end
