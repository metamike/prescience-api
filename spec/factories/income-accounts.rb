FactoryGirl.define do
  factory :income_account do
    name           Faker::Name
    starting_month Month.new(2014, 1)
    annual_gross   Faker::Number.number(6).to_i

    scenario
  end

end
