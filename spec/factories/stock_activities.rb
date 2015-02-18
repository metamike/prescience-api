FactoryGirl.define do
  factory :stock_activity do
    month       { build(:month, year: 2014, month: 9) }
    performance Faker::Number.number(5).to_i / 100.0

    stock_bundle
  end
end
