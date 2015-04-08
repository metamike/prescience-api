FactoryGirl.define do
  factory :income_tax_activity do
    year          { Faker::Number.number(4).to_i }
    filing_status 'single'
    income_tax_account

    wages                         { Faker::Number.number(8).to_i / 100.0 }
    taxable_interest              { Faker::Number.number(4).to_i / 100.0 }
    taxable_dividends             { Faker::Number.number(5).to_i / 100.0 }
    qualified_dividends           { Faker::Number.number(5).to_i / 100.0 }
    short_term_capital_net        { Faker::Number.number(5).to_i / 100.0 }
    long_term_capital_net         { Faker::Number.number(6).to_i / 100.0 }
    federal_income_tax_withheld   { Faker::Number.number(7).to_i / 100.0 }
    social_security_tax_withheld  { Faker::Number.number(6).to_i / 100.0 }
    state_income_tax_withheld     { Faker::Number.number(7).to_i / 100.0 }
    state_disability_tax_withheld { Faker::Number.number(6).to_i / 100.0 }

    capital_net                 { Faker::Number.number(6).to_i / 100.0 }
    adjusted_gross_income       { Faker::Number.number(7).to_i / 100.0 }
    taxable_income              { Faker::Number.number(7).to_i / 100.0 }
    federal_itemized_deductions { Faker::Number.number(6).to_i / 100.0 }
    federal_income_tax          { Faker::Number.number(6).to_i / 100.0 }
    federal_income_tax_owed     { Faker::Number.number(6).to_i / 100.0 }
    state_income_tax            { Faker::Number.number(6).to_i / 100.0 }
    state_income_tax_owed       { Faker::Number.number(6).to_i / 100.0 }
  end

end
