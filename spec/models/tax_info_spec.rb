require 'rails_helper'

describe TaxInfo, type: :model do
  context 'validations' do
    [:starting_year, :social_security_wage_limit, :state_disability_wage_limit,
        :annual_401k_contribution_limit].each do |field|
      it { should validate_presence_of(field) }
      it { should validate_numericality_of(field) }
    end
  end

  let(:tax_info) { build(:tax_info) }

  describe '#social_security_wage_limit_for_year' do
    it 'should fail when year is before starting year' do
      expect { tax_info.social_security_wage_limit_for_year(tax_info.starting_year - 1) }.to raise_error
    end
    it 'should return starting value for starting year' do
      expect(tax_info.social_security_wage_limit_for_year(tax_info.starting_year)).to eq(tax_info.social_security_wage_limit)
    end
    it 'should calculate following years'' wage limit' do
      years = 3
      limit = tax_info.social_security_wage_limit
      years.times { limit = (limit * (1 + tax_info.social_security_wage_limit_growth_rate.mean)).round(2) }
      expect(tax_info.social_security_wage_limit_for_year(tax_info.starting_year + years)).to eq(limit)
    end
  end

  describe '#state_disability_wage_limit_for_year' do
    it 'should fail when year is before starting year' do
      expect { tax_info.state_disability_wage_limit_for_year(tax_info.starting_year - 1) }.to raise_error
    end
    it 'should return starting value for starting year' do
      expect(tax_info.state_disability_wage_limit_for_year(tax_info.starting_year)).to eq(tax_info.state_disability_wage_limit)
    end
    it 'should calculate following years'' wage limit' do
      years = 3
      limit = tax_info.state_disability_wage_limit
      years.times { limit = (limit * (1 + tax_info.state_disability_wage_limit_growth_rate.mean)).round(2) }
      expect(tax_info.state_disability_wage_limit_for_year(tax_info.starting_year + years)).to eq(limit)
    end
  end
end
