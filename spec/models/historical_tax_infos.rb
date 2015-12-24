require 'rails_helper'

describe HistoricalTaxInfo, type: :model do

  context 'validations' do
    [:year, :social_security_wage_limit, :state_disability_wage_limit,
        :annual_401k_contribution_limit, :standard_deduction, :max_capital_loss,
        :personal_exemption_income_limit_single, :personal_exemption_income_limit_married,
        :personal_exemption].each do |field|
      it { should validate_presence_of(field) }
      it { should validate_numericality_of(field) }
    end
  end

  describe '#federal_tax' do
    let(:historical) { build(:historical_tax_info) }
    let(:low_bracket) { build(:tax_bracket) }
    let(:high_bracket) { build(:tax_bracket, :high_income) }
    let(:low_income) { BigDecimal.new(low_bracket.lower_bound + 1000) }
    before :each do
      historical.tax_brackets += [low_bracket, high_bracket]
    end
    it 'should find the right bracket' do
      tax = low_bracket.tax(low_income)
      expect(historical.federal_tax(low_bracket.filing_status, low_income)).to eq(tax)
    end
  end

end
