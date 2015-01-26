FactoryGirl.define do
  factory :savings_account_activity do
    interest       Faker::Number.number(4).to_i / 100.0
    ending_balance Faker::Number.number(10).to_i / 100.0

    savings_account
  end

end
