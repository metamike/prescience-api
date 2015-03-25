require 'rails_helper'

describe IncomeAccountActivity, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:month) }
    [:gross, :federal_income_tax, :social_security_tax, :medicare_tax,
        :state_income_tax, :state_disability_tax, :net].each do |field|
      it { should validate_presence_of(field) }
      it { should validate_numericality_of(field) }
    end
    it { should validate_numericality_of(:pretax_401k_contribution) }
    it { should validate_numericality_of(:aftertax_401k_contribution) }
  end

end

