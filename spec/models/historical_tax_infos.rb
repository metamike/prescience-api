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

end
