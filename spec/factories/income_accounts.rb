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
  end

end
