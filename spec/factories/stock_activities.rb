FactoryGirl.define do
  factory :stock_activity do
    month       { build(:month, year: 2014, month: 9) }
    performance { Faker::Number.number(5).to_i / 100.0 }
    dividends   { Faker::Number.number(4).to_i / 100.0 }

    trait :sale do
      sold { Faker::Number.number(4).to_i / 100.0 }
    end

    stock_bundle
  end
end
