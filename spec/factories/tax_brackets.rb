FactoryGirl.define do
  factory :tax_bracket do
    historical_tax_info
    type          'federal'
    filing_status 'single'
    lower_bound   BigDecimal.new('140000')
    slope         0.33
    intercept     BigDecimal.new('5000')

    trait :married do
      filing_status 'married'
      lower_bound   BigDecimal.new('80000')
      slope         0.25
      intercept     BigDecimal.new('-2000')
    end

    trait :high_income do
      lower_bound BigDecimal.new('200000')
      slope       0.38
      intercept   BigDecimal.new('8000')
    end
  end
end
