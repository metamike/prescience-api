FactoryGirl.define do
  factory :income_account_activity do
    gross Faker::Number.number(8).to_i / 100.0

    income_account
  end

end
