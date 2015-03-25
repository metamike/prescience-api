FactoryGirl.define do
  factory :tax_info do
    starting_year { Faker::Number.number(4).to_i }
    social_security_wage_limit { Faker::Number.number(8).to_i / 100.0 }
    social_security_wage_limit_growth_rate { build(:random_variable, :no_stdev, mean: 0.02) }
    state_disability_wage_limit { Faker::Number.number(7).to_i / 100.0 }
    state_disability_wage_limit_growth_rate { build(:random_variable, :no_stdev, mean: 0.03) }
  end
end
