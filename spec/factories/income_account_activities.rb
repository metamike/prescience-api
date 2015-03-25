FactoryGirl.define do
  factory :income_account_activity do
    gross                { Faker::Number.number(8).to_i / 100.0 }
    federal_income_tax   { Faker::Number.number(6).to_i / 100.0 }
    social_security_tax  { Faker::Number.number(5).to_i / 100.0 }
    medicare_tax         { Faker::Number.number(5).to_i / 100.0 }
    state_income_tax     { Faker::Number.number(6).to_i / 100.0 }
    state_disability_tax { Faker::Number.number(5).to_i / 100.0 }
    net                  { Faker::Number.number(7).to_i / 100.0 }

    pretax_401k_contribution   { Faker::Number.number(5).to_i / 100.0 }
    aftertax_401k_contribution { Faker::Number.number(5).to_i / 100.0 }

    income_account

    trait :for_summary_low do
      month Month.new(2014, 1)
      gross BigDecimal.new('9500')
    end

    trait :for_summary_high do
      month Month.new(2014, 1)
      gross BigDecimal.new('13333.33')
    end
  end

end
