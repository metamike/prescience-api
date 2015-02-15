FactoryGirl.define do

  factory :random_variable do
    mean  Faker::Number.number(5).to_i / 100.0
    stdev Faker::Number.number(4).to_i / 100.0

    trait :no_stdev do
      stdev nil
    end

  end

end
