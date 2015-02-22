FactoryGirl.define do
  factory :mutual_fund do
    name                    Faker::Lorem.word
    starting_month          { build(:month, year: 2014, month: 9) }
    monthly_interest_rate   { build(:random_variable, :no_stdev, mean: 0.07/12) }
    quarterly_dividend_rate { build(:random_variable, :no_stdev, mean: 0.025/4) }

    scenario
  end

end