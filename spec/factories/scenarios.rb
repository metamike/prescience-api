FactoryGirl.define do
  factory :scenario do
    name { Faker::Lorem.sentence }
    starting_month    { build(:month, year: 2014, month: 9) }
    projections_start { starting_month }

    tax_info

    trait :with_historicals do
      projections_start { starting_month.next }
    end
  end

end
