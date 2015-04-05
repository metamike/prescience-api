FactoryGirl.define do
  factory :tax_info do
    starting_year { Faker::Number.number(4).to_i }
    social_security_wage_limit             { Faker::Number.number(8).to_i / 100.0 }
    social_security_wage_limit_growth_rate { build(:random_variable, :no_stdev, mean: 0.02) }
    state_disability_wage_limit             { Faker::Number.number(7).to_i / 100.0 }
    state_disability_wage_limit_growth_rate { build(:random_variable, :no_stdev, mean: 0.03) }
    annual_401k_contribution_limit             { Faker::Number.number(7).to_i / 100.0 }
    annual_401k_contribution_limit_growth_rate { build(:random_variable, :no_stdev, mean: 0.03) }
    max_capital_loss { Faker::Number.number(6).to_i / 100.0 }
    standard_deduction             { Faker::Number.number(6).to_i / 100.0 }
    standard_deduction_growth_rate { build(:random_variable, :no_stdev, mean: 0.03) }
  end
end
