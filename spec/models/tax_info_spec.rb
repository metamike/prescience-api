require 'rails_helper'

describe TaxInfo, type: :model do
  let(:tax_info) { build(:tax_info) }

  describe '#social_security_wage_limit' do
    it 'should fail with no historicals' do
      expect { tax_info.social_security_wage_limit(1000) }.to raise_error
    end

    context 'with historicals' do
      let(:historical) { build(:historical_tax_info) }
      before :each do
        tax_info.historical_tax_infos << historical
      end
      it 'should fail when year is before starting year' do
        expect { tax_info.social_security_wage_limit(historical.year - 1) }.to raise_error
      end
      it 'should return starting value for starting year' do
        expect(tax_info.social_security_wage_limit(historical.year)).to eq(historical.social_security_wage_limit)
      end
      it 'should calculate following years'' wage limit' do
        years = 3
        limit = historical.social_security_wage_limit
        years.times { limit = (limit * (1 + tax_info.social_security_wage_limit_growth_rate.mean)).round(2) }
        expect(tax_info.social_security_wage_limit(historical.year + years)).to eq(limit)
      end
    end
  end

  describe '#state_disability_wage_limit' do
    it 'should fail with no historicals' do
      expect { tax_info.state_disability_wage_limit(1000) }.to raise_error
    end

    context 'with historicals' do
      let(:historical) { build(:historical_tax_info) }
      before :each do
        tax_info.historical_tax_infos << historical
      end
      it 'should fail when year is before starting year' do
        expect { tax_info.state_disability_wage_limit(historical.year - 1) }.to raise_error
      end
      it 'should return starting value for starting year' do
        expect(tax_info.state_disability_wage_limit(historical.year)).to eq(historical.state_disability_wage_limit)
      end
      it 'should calculate following years'' wage limit' do
        years = 4
        limit = historical.state_disability_wage_limit
        years.times { limit = (limit * (1 + tax_info.state_disability_wage_limit_growth_rate.mean)).round(2) }
        expect(tax_info.state_disability_wage_limit(historical.year + years)).to eq(limit)
      end
    end
  end
end
