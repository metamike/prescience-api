FactoryGirl.define do
  factory :expense_account do
    name            Faker::Name
    starting_month  Month.new(2014, 9)
    starting_amount Faker::Number.number(6).to_i / 100.0

    scenario
  end

end
