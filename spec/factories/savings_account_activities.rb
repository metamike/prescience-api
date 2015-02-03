FactoryGirl.define do
  factory :savings_account_activity do
    interest       Faker::Number.number(4).to_i / 100.0
    ending_balance Faker::Number.number(10).to_i / 100.0

    savings_account

    trait :for_summary_low do
      month          Month.new(2014, 1)
      interest       BigDecimal.new('0.16')
      ending_balance BigDecimal.new('26020.50')
    end

    trait :for_summary_high do
      month          Month.new(2014, 1)
      interest       BigDecimal.new('2.50')
      ending_balance BigDecimal.new('33000.30')
    end
  end

end
