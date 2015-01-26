FactoryGirl.define do
  factory :savings_account do
    starting_balance Faker::Number.number(8).to_i / 100.0
    starting_month   Month.new(2014, 9)
    interest_rate    Faker::Number.number(2).to_i / 10000.0

    scenario
  end

end
