FactoryGirl.define do
  factory :historical_tax_info do
    year   { Faker::Number.number(4).to_i }
    social_security_wage_limit     { Faker::Number.number(8).to_i / 100.0 }
    state_disability_wage_limit    { Faker::Number.number(8).to_i / 100.0 }
    annual_401k_contribution_limit { Faker::Number.number(7).to_i / 100.0 }
    max_capital_loss               { Faker::Number.number(6).to_i / 100.0 }
    standard_deduction             { Faker::Number.number(6).to_i / 100.0 }
    personal_exemption_income_limit_single  { Faker::Number.number(8).to_i / 100.0 }
    personal_exemption_income_limit_married { Faker::Number.number(8).to_i / 100.0 }
    personal_exemption             { Faker::Number.number(6).to_i / 100.0 }
  end
end
