require 'rails_helper'

describe IncomeTaxActivity, model: true do

  context 'validations' do
    it { should validate_presence_of(:year) }
    it { should validate_numericality_of(:year) }
    it { should validate_presence_of(:filing_status) }
    it { should validate_inclusion_of(:filing_status).in_array(%w(single married)) }
    [:capital_net, :federal_income_tax_withheld, :social_security_tax_withheld,
        :state_income_tax_withheld, :state_disability_tax_withheld, :adjusted_gross_income,
        :taxable_income, :federal_itemized_deductions, :federal_income_tax,
        :federal_income_tax_owed, :state_income_tax, :state_income_tax_owed,
        :mortgage_starting_balance, :mortgage_ending_balance].each do |field|
      it { should validate_numericality_of(field) }
    end
  end

end

