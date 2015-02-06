FactoryGirl.define do
  factory :expense_account_activity do
    amount Faker::Number.number(6).to_i / 100.0

    expense_account

    trait :for_summary_groceries do
      month  Month.new(2014, 1)
      amount BigDecimal.new('1120.50')
    end

    trait :for_summary_entertainment do
      month  Month.new(2014, 1)
      amount BigDecimal.new('91')
    end
  end

end
