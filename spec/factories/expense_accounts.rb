FactoryGirl.define do
  factory :expense_account do
    name            Faker::Lorem.word
    starting_month  Month.new(2014, 9)
    starting_amount Faker::Number.number(6).to_i / 100.0

    scenario

    trait :with_raise do
      rate_of_increase { build(:random_variable, :no_stdev, mean: Faker::Number.number(2).to_i / 12000.0) }
    end

    trait :with_uncertain_raise do
      rate_of_increase { build(:random_variable, mean: Faker::Number.number(2).to_i / 100.0) }
    end

    trait :with_annual_raise do
      increase_schedule 'yearly'
    end

    trait :with_uncertainty do
      stdev_coefficient { starting_amount / 2 }
    end

    trait :with_random_months do
      month_coefficients { 12.times.map { Random.rand(4) / 2.0 } }
    end

    trait :with_year_interval do
      year_interval Random.rand(2) + 2
    end

    trait :for_summary_groceries do
      name             'Groceries'
      starting_month   Month.new(2014, 1)
      starting_amount  BigDecimal.new('1200')
      rate_of_increase { build(:random_variable, :no_stdev, mean: 0.0025) }
    end

    trait :for_summary_entertainment do
      name            'Entertainment'
      starting_month  Month.new(2014, 1)
      starting_amount BigDecimal.new('80')
    end
  end

end
