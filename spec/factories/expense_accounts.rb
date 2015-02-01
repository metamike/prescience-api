FactoryGirl.define do
  factory :expense_account do
    name            Faker::Lorem.word
    starting_month  Month.new(2014, 9)
    starting_amount Faker::Number.number(6).to_i / 100.0

    scenario

    trait :with_raise do
      rate_of_increase Faker::Number.number(2).to_i / 12000.0
    end

    trait :with_annual_raise do
      rate_of_increase Faker::Number.number(2).to_i / 12000.0
      increase_schedule 'yearly'
    end

    trait :with_random_months do
      month_coefficients 12.times.map { Random.rand(4) / 2.0 }
    end

    trait :with_year_interval do
      year_interval Random.rand(2) + 2
    end
  end

end
