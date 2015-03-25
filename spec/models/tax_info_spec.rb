require 'rails_helper'

describe TaxInfo, type: :model do
  context 'validations' do
    it { should validate_presence_of(:starting_year) }
    it { should validate_numericality_of(:starting_year) }
    it { should validate_presence_of(:social_security_wage_limit) }
    it { should validate_numericality_of(:social_security_wage_limit) }
    it { should validate_presence_of(:state_disability_wage_limit) }
    it { should validate_numericality_of(:state_disability_wage_limit) }
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
