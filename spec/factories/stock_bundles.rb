FactoryGirl.define do
  factory :stock_bundle do
    month_bought { build(:month, year: 2014, month: 9) }
    amount       Faker::Number.number(6).to_i / 100.0

    mutual_fund
  end
end
