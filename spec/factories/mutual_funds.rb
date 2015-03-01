FactoryGirl.define do
  factory :mutual_fund do
    name                    Faker::Lorem.word
    starting_month          { build(:month, year: 2014, month: 9) }
    monthly_interest_rate   { build(:random_variable, :no_stdev, mean: 0.07/12) }
    quarterly_dividend_rate { build(:random_variable, :no_stdev, mean: 0.025/4) }

    scenario

    trait :with_uncertain_interest do
      monthly_interest_rate { build(:random_variable, mean: 0.02/12, stdev: 0.04/12) }
    end

    trait :for_summary do
      monthly_interest_rate { build(:random_variable, mean: 0.007, stdev: 0.0415) }
      quarterly_dividend_rate { build(:random_variable, mean: 0.0055, stdev: 0.0026) }
    end
  end

end
