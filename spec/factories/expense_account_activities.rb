FactoryGirl.define do
  factory :expense_account_activity do
    amount Faker::Number.number(6).to_i / 100.0

    expense_account
  end

end
