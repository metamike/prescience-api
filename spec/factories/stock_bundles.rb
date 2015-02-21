FactoryGirl.define do
  factory :stock_bundle do
    month_bought { build(:month, year: 2014, month: 9) }
    amount       Faker::Number.number(6).to_i / 100.0

    mutual_fund

    trait :with_activity do
      after :build do |bundle, evaluator|
        create(:stock_activity, month: bundle.month_bought, stock_bundle: bundle)
        bundle.reload   # ANNOYING!
      end
    end

    trait :with_activities do
      after :build do |bundle, evaluator|
        create(:stock_activity, month: bundle.month_bought.next, stock_bundle: bundle)
        create(:stock_activity, month: bundle.month_bought, stock_bundle: bundle)
        bundle.reload
      end
    end

    trait :with_sale do
      after :build do |bundle, evaluator|
        create(:stock_activity, :sale, month: bundle.month_bought, stock_bundle: bundle)
        bundle.reload
      end
    end

    trait :with_qualified_activity do
      after :build do |bundle, evaluator|
        current = bundle.month_bought
        14.times do
          create(:stock_activity, month: current, stock_bundle: bundle)
          current = current.next
        end
        bundle.reload
      end
    end
  end
end
