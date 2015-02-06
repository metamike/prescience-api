FactoryGirl.define do
  factory :income_account_activity do
    gross Faker::Number.number(8).to_i / 100.0

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
