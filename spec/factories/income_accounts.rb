FactoryGirl.define do
  factory :income_account do
    name           Faker::Name
    starting_month Month.new(2014, 9)
    annual_gross   Faker::Number.number(6).to_i

    savings_account
    scenario
  end

end
