FactoryGirl.define do
  factory :home_equity_account do
    month_bought     { build(:month, year: 2014, month: 11) }
    loan_amount      { Faker::Number.number(8).to_i / 100.0 }
    loan_term_months { Faker::Number.number(3).to_i + 10 }
    interest_rate    { Faker::Number.number(2).to_i / 1000.0 }

    scenario

    trait :with_activity do
      after :build do |account, evaluator|
        create(:home_equity_account_activity, month: account.month_bought, home_equity_account: account)
        account.reload   # ANNOYING!
      end
    end
  end

end
