FactoryGirl.define do
  factory :home_equity_account_activity do
    month
    principal { Faker::Number.number(6).to_i / 100.0 }
    interest  { Faker::Number.number(6).to_i / 100.0 }

    home_equity_account
  end

end
