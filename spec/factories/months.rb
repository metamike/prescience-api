FactoryGirl.define do
  factory :month do
    year  Faker::Number.number(4).to_i
    month Faker::Number.number(1).to_i + 1
  end
end
