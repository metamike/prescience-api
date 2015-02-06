FactoryGirl.define do
  factory :income_account do
    name           Faker::Name
    starting_month Month.new(2014, 9)
    annual_gross   Faker::Number.number(6).to_i

    savings_account
    scenario

    trait :with_raise do
      annual_raise Faker::Number.number(3).to_i / 1000.0
    end

    trait :for_summary_low do
      name           'Lower Income'
      starting_month Month.new(2014, 1)
      annual_gross   BigDecimal.new('120000')
      annual_raise   BigDecimal.new('0.035')
    end

    trait :for_summary_high do
      name           'Higher Income'
      starting_month Month.new(2014, 1)
      annual_gross   BigDecimal.new('160000')
      annual_raise   BigDecimal.new('0.028')
    end
  end

end
