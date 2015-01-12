FactoryGirl.define do
  factory :scenario do
    name { Faker::Lorem.sentence }
  end

end
