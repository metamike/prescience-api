FactoryGirl.define do
  factory :scenario do
    name { Faker::Lorem.sentence }
    projections_start { build(:month, year: 2014, month: 9) }
  end

end
