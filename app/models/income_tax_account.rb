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
    @transactions[tax_year(month)][:federal_itemized_deductions] = TaxFormBuilder.form_set.f1040.itemized_deductions
    @transactions[tax_year(month)][:federal_income_tax] = TaxFormBuilder.form_set.f1040.federal_income_tax
    @transactions[tax_year(month)][:federal_income_tax_owed] = TaxFormBuilder.form_set.f1040.federal_income_tax_owed
    @transactions[tax_year(month)][:state_income_tax] = TaxFormBuilder.form_set.ca540.state_income_tax
    @transactions[tax_year(month)][:state_income_tax_owed] = TaxFormBuilder.form_set.ca540.state_income_tax_owed
  end

  def transact(month)
    return unless month.month == TAX_MONTH
    raise "No projection for #{month}. Please run #project first" unless @transactions[tax_year(month)]
    expense(month, @transactions[tax_year(month)][:federal_income_tax_owed] +
                   @transactions[tax_year(month)][:state_income_tax_owed])
  end

  def federal_itemized_deductions(tax_year)
    @transactions[tax_year] ? @transactions[tax_year][:federal_itemized_deductions] : 0
  end

  def federal_income_tax(tax_year)
    @transactions[tax_year] ? @transactions[tax_year][:federal_income_tax] : 0
  end

  def federal_income_tax_owed(tax_year)
    @transactions[tax_year] ? @transactions[tax_year][:federal_income_tax_owed] : 0
  end

  def state_income_tax(tax_year)
    @transactions[tax_year] ? @transactions[tax_year][:state_income_tax] : 0
  end

  def state_income_tax_owed(tax_year)
    @transactions[tax_year] ? @transactions[tax_year][:state_income_tax_owed] : 0
  end

  def summary(month)
    if month.month != TAX_MONTH
      {'income taxes' => {'federal income taxes' => 0, 'state income taxes' => 0}}
    else
      {
        'income taxes' => {
          'federal income taxes' => federal_income_tax_owed(tax_year(month)),
          'state income taxes' => state_income_tax_owed(tax_year(month))
        }
      }
    end
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
    @transactions[activity.year][:federal_itemized_deductions] = activity.federal_itemized_deductions
    @transactions[activity.year][:federal_income_tax] = activity.federal_income_tax
    @transactions[activity.year][:federal_income_tax_owed] = activity.federal_income_tax_owed
    @transactions[activity.year][:state_income_tax] = activity.state_income_tax
    @transactions[activity.year][:state_income_tax_owed] = activity.state_income_tax_owed
  end

  def tax_year(month)
    month.year - 1
  end

end
