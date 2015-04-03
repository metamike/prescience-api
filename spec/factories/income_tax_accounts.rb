FactoryGirl.define do
  factory :income_tax_account do
    scenario
    owner
    filing_status 'single'

    trait :with_activity do
      after :build do |account, evaluator|
        account.income_tax_activities << build(:income_tax_activity)
      end
    end
  end
end
