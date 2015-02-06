FactoryGirl.define do
  factory :savings_account do
    starting_balance Faker::Number.number(8).to_i / 100.0
    starting_month   Month.new(2014, 9)
    interest_rate    Faker::Number.number(2).to_i / 10000.0

    scenario

    trait :for_summary_low do
      starting_month   Month.new(2014, 1)
      starting_balance BigDecimal.new('22000.00')
      interest_rate    BigDecimal.new('0.00002')
    end

    trait :for_summary_high do
      starting_month   Month.new(2014, 1)
      starting_balance BigDecimal.new('29500.00')
      interest_rate    BigDecimal.new('0.00008')
    end
  end

end
