require 'rails_helper'

describe TaxBracket, type: :model do

  let(:bracket) { build(:tax_bracket) }

  context 'validations' do
    [:type, :filing_status, :lower_bound, :slope, :intercept].each do |field|
      it { should validate_presence_of(field) }
    end
    it { should validate_inclusion_of(:type).in_array(%w(federal state)) }
    it { should validate_inclusion_of(:filing_status).in_array(%w(single married)) }
  end

  describe '#tax' do
    let(:income) { BigDecimal.new('5000') }
    it 'should calculate correctly' do
      tax = (income * bracket.slope + bracket.intercept).round(2)
      expect(bracket.tax(income)).to eq(tax)
    end
  end

end
