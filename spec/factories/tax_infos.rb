FactoryGirl.define do
  factory :tax_info do
    social_security_wage_limit_growth_rate     { build(:random_variable, :no_stdev, mean: 0.02) }
    state_disability_wage_limit_growth_rate    { build(:random_variable, :no_stdev, mean: 0.03) }
    annual_401k_contribution_limit_growth_rate { build(:random_variable, :no_stdev, mean: 0.03) }
    standard_deduction_growth_rate             { build(:random_variable, :no_stdev, mean: 0.03) }
    max_capital_loss_growth_rate               { build(:random_variable, :no_stdev, mean: 0) }
  end
end
