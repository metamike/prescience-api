task :seeding do

# Scenarios
scenario = Scenario.find_by_name('ROOT')
unless scenario
  scenario = Scenario.create!(
    name: 'ROOT',
    starting_month: Month.new(2013, 7),
    projections_start: Month.new(2015, 2)
  )
end

# Tax Info
tax_info = TaxInfo.first
unless tax_info
  tax_info = TaxInfo.create!(
    social_security_wage_limit_growth_rate: RandomVariable.new(0.022, 0.015),
    state_disability_wage_limit_growth_rate: RandomVariable.new(0.019, 0.1),
    annual_401k_contribution_limit_growth_rate: RandomVariable.new(0.03, 0.01),
    standard_deduction_growth_rate: RandomVariable.new(0.022, 0.005),
    max_capital_loss_growth_rate: RandomVariable.new(0, 0),
    personal_exemption_income_limit_growth_rate: RandomVariable.new(0.02, 0.001),
    personal_exemption_growth_rate: RandomVariable.new(0.02, 0.005)
  )
  scenario.tax_info = tax_info
  scenario.save!
end
unless HistoricalTaxInfo.find_by_year(2013)
  historical = HistoricalTaxInfo.create!(
    year: 2013,
    social_security_wage_limit: BigDecimal.new('113700'),
    state_disability_wage_limit: BigDecimal.new('100880'),
    annual_401k_contribution_limit: BigDecimal.new('17000'),
    standard_deduction: BigDecimal.new('6100'),
    max_capital_loss: BigDecimal.new('3000'),
    personal_exemption_income_limit_single: BigDecimal.new('250000'),
    personal_exemption_income_limit_married: BigDecimal.new('300000'),
    personal_exemption: BigDecimal.new('3900')
  )
  tax_info.historical_tax_infos << historical
  tax_info.save!
end
unless HistoricalTaxInfo.find_by_year(2014)
  historical = HistoricalTaxInfo.create!(
    year: 2014,
    social_security_wage_limit: BigDecimal.new('117000'),
    state_disability_wage_limit: BigDecimal.new('101636'),
    annual_401k_contribution_limit: BigDecimal.new('17500'),
    standard_deduction: BigDecimal.new('6200'),
    max_capital_loss: BigDecimal.new('3000'),
    personal_exemption_income_limit_single: BigDecimal.new('254200'),
    personal_exemption_income_limit_married: BigDecimal.new('305050'),
    personal_exemption: BigDecimal.new('3950')
  )
  tax_info.historical_tax_infos << historical
  tax_info.save!
end
unless HistoricalTaxInfo.find_by_year(2015)
  historical = HistoricalTaxInfo.create!(
    year: 2015,
    social_security_wage_limit: BigDecimal.new('118500'),
    state_disability_wage_limit: BigDecimal.new('104378'),
    annual_401k_contribution_limit: BigDecimal.new('18000'),
    standard_deduction: BigDecimal.new('6300'),
    max_capital_loss: BigDecimal.new('3000')
  )
  tax_info.historical_tax_infos << historical
  tax_info.save!
end

# Owners
mike = Owner.find_by_name('Mike') || Owner.create!(name: 'Mike')
robin = Owner.find_by_name('Robin') || Owner.create!(name: 'Robin')

# Income Taxes
unless IncomeTaxAccount.find_by_owner_id(mike.id)
  mike_income_tax = IncomeTaxAccount.create!(
    owner: mike,
    filing_status: 'single'
  )
  scenario.income_tax_accounts << mike_income_tax
  scenario.save!
  activity_2013 = IncomeTaxActivity.create!(
    year: 2013,
    filing_status: 'single',
    wages: BigDecimal.new('182699.22'),
    taxable_interest: BigDecimal.new('4.69'),
    taxable_dividends: BigDecimal.new('1892.15'),
    qualified_dividends: BigDecimal.new('1623.60'),
    short_term_capital_net: BigDecimal.new('0'),
    long_term_capital_net: BigDecimal.new('18692.09'),
    capital_net: BigDecimal.new('18692.09'),
    adjusted_gross_income: BigDecimal.new('203849.15'),
    taxable_income: BigDecimal.new('149688.80'),
    federal_itemized_deductions: BigDecimal.new('50260.35'),
    federal_income_tax: BigDecimal.new('32565.08'),
    federal_income_tax_owed: BigDecimal.new('-9260.97'),
    state_income_tax: BigDecimal.new('15092'),
    state_income_tax_owed: BigDecimal.new('-917')
  )
  mike_income_tax.income_tax_activities << activity_2013
  mike_income_tax.save!
end

# Savings
unless SavingsAccount.find_by_owner_id(mike.id)
  mike_savings = SavingsAccount.create!(
    owner: mike,
    starting_month: Month.new(2015, 2),
    starting_balance: BigDecimal.new('45298'),
    monthly_interest_rate: RandomVariable.new(0.00002, 0.00001)
  )
  scenario.savings_accounts << mike_savings
  scenario.save!
end
unless SavingsAccount.find_by_owner_id(robin.id)
  robin_savings = SavingsAccount.create!(
    owner: robin,
    starting_month: Month.new(2015, 2),
    starting_balance: BigDecimal.new('75311'),
    monthly_interest_rate: RandomVariable.new(0.00008, 0.00001)
  )
  scenario.savings_accounts << robin_savings
  scenario.save!
end

# Income
unless IncomeAccount.find_by_owner_id(mike.id)
  mike_income = IncomeAccount.create!(
    name: 'Mike''s Income',
    owner: mike,
    starting_month: Month.new(2015, 2),
    annual_raise: RandomVariable.new(0.03, 0.02),
    annual_salary: BigDecimal.new('170000')
  )
  [
    ['2014-01', 14166.66, 2770.02,  870.52, 203.59, 1121.47, 140.40, 566.68,  8493.98],
    ['2014-02', 14166.66, 2736.70,  863.14, 201.86, 1109.29, 139.22, 566.68,  8549.77],
    ['2014-03', 14166.66, 2749.52,  865.98, 202.53, 1113.98, 139.68, 566.68,  8528.29],
    ['2014-04', 19166.66, 3500.86, 1173.14, 274.36, 1610.56, 189.22, 766.68, 11651.84],
    ['2014-05', 14166.66, 2275.86,  863.14, 201.87, 1109.29, 139.22, 566.68,  9010.60],
    ['2014-06', 14166.66, 2275.86,  863.14, 201.86, 1109.29, 139.22, 566.68,  9010.61],
    ['2014-07', 14166.66, 2275.86,  863.14, 201.86, 1109.29, 129.40, 566.68,  9020.43],
    ['2014-08', 14166.66, 2344.48,  878.33, 205.42, 1134.36,   0.00, 566.68,  9037.39],
    ['2014-09', 14166.66, 2344.48,   13.47, 205.42, 1134.36,   0.00, 566.68,  9902.25],
    ['2014-10', 14166.66, 2344.48,    0.00, 205.41, 1134.36,   0.00, 566.68,  9915.73],
    ['2014-11', 14166.66, 2344.48,    0.00, 205.42, 1134.36,   0.00, 566.68,  9915.72],
    ['2014-12', 14166.66, 2344.48,    0.00, 205.42, 1134.36,   0.00, 566.68,  9915.72],
    ['2015-01', 14166.66, 2286.53,  870.27, 203.53, 1114.88, 126.33, 566.68,  8998.44]
  ].each do |d|
    activity = IncomeAccountActivity.create!(
      month: Month.parse(d[0]),
      gross: BigDecimal.new(d[1].to_s),
      federal_income_tax: BigDecimal.new(d[2].to_s),
      social_security_tax: BigDecimal.new(d[3].to_s),
      medicare_tax: BigDecimal.new(d[4].to_s),
      state_income_tax: BigDecimal.new(d[5].to_s),
      state_disability_tax: BigDecimal.new(d[6].to_s),
      pretax_401k_contribution: BigDecimal.new((d[7]/2.0).to_s).round(2),
      aftertax_401k_contribution: BigDecimal.new((d[7]/2.0).to_s).round(2),
      net: BigDecimal.new(d[8].to_s)
    )
    mike_income.income_account_activities << activity
    mike_income.save!
  end
  scenario.income_accounts << mike_income
  scenario.save!
end
unless IncomeAccount.find_by_owner_id(robin.id)
  robin_income = IncomeAccount.create!(
    name: 'Robin''s Income',
    owner: robin,
    starting_month: Month.new(2015, 2),
    annual_raise: RandomVariable.new(0.03, 0.02),
    annual_salary: BigDecimal.new('150000')
  )
  scenario.income_accounts << robin_income
  scenario.save!
end

# Expenses
unless ExpenseAccount.find_by_name('Expenses')
  expenses = ExpenseAccount.create!(
    name: 'Expenses',
    starting_month: Month.new(2015, 2),
    starting_amount: BigDecimal.new('12900'),
    rate_of_increase: RandomVariable.new(0.03/12, 0.02/12),
    stdev_coefficient: 0.1
  )
  scenario.expense_accounts << expenses
  scenario.save!
end

# Home Equity
unless HomeEquityAccount.any?
  home_equity = HomeEquityAccount.create!(
    month_bought: Month.new(2013, 7),
    loan_amount: BigDecimal.new('1064000'),
    interest_rate: BigDecimal.new('0.04125'),
    loan_term_months: 360,
    owner: mike
  )
  equity_data = [
    ['2013-07',    0,       0   ],
    ['2013-08',    0,       0   ],
    ['2013-09', 1499.17, 3657.50],
    ['2013-10', 3013.81, 7299.53],
    ['2013-11',    0,       0   ],
    ['2013-12', 1514.68, 3641.99],
    ['2014-01', 1519.89, 3636.78],
    ['2014-02', 3055.47, 7257.87],
    ['2014-03',    0,       0   ],
    ['2014-04', 1535.62, 3621.05],
    ['2014-05', 1540.90, 3615.77],
    ['2014-06', 1546.19, 3610.48],
    ['2014-07', 1551.51, 3605.16],
    ['2014-08', 1556.84, 3599.83],
    ['2014-09', 1562.19, 3594.48],
    ['2014-10', 1567.56, 3589.11],
    ['2014-11', 1572.95, 3583.72],
    ['2014-12', 1578.36, 3578.31],
    ['2015-01', 1583.78, 3572.89]
  ]
  equity_data.each do |row|
    HomeEquityAccountActivity.create!(
      month: Month.parse(row[0]),
      principal: BigDecimal.new(row[1].to_s),
      interest: BigDecimal.new(row[2].to_s),
      home_equity_account: home_equity
    )
  end
  scenario.home_equity_accounts << home_equity
  scenario.save!
end

# Mutual Funds
unless MutualFund.find_by_name('Vanguard Stock Fund')
  vanguard_stock_fund = MutualFund.create!(
    name: 'Vanguard Stock Fund',
    owner: mike,
    starting_month: Month.new(2014, 1),
    monthly_interest_rate: RandomVariable.new(0.007, 0.0415),
    quarterly_dividend_rate: RandomVariable.new(0.0055, 0.0026)
  )
  # Stock Data!!
  stock_data = {
    '2014-01' => [69095.08,
      [[-2380.96, 0],      [3258.47, 0],      [5.79, 342.89], [224.74, 0],
       [1484.71, 0],       [1312.03, 406.89], [-1384.53, 0],  [2531.66, 0],
       [-2337.70, 340.37], [1544.49, 0],      [1398.84, 0],   [-941.16, 430.43],
       [-1647.47, 0]]],
    '2014-03' => [342.89,
      [[0, 0],     [1.07, 0],     [7.04, 0],      [6.42, 1.99],
       [-6.78, 0], [12.40, 0],    [-11.45, 1.67], [7.56, 0],
       [6.85, 0],  [-4.61, 2.11], [-8.07, 0]]],
    '2014-06' => [408.88,
      [[0, 0],    [-7.76, 0], [14.18, 0],    [-13.09, 1.91],
       [8.65, 0], [7.84, 0],  [-5.27, 2.41], [-9.23, 0]]],
    '2014-09' => [343.95,
      [[0, 0], [7.40, 0], [6.70, 0], [-4.51, 2.06],
       [-7.89, 0]]],
    '2014-12' => [437.01,
      [[0, 0], [-9.75, 0]]],
  }
  # Bundles & Activity
  stock_data.each do |bundle_month, bundle_data|
    bundle = StockBundle.create!(
      month_bought: Month.parse(bundle_month),
      amount: BigDecimal.new(bundle_data.first.to_s),
      mutual_fund: vanguard_stock_fund
    )
    current_month = bundle.month_bought
    bundle_data.last.each do |activity_data|
      activity = StockActivity.create!(
        month: current_month,
        performance: BigDecimal.new(activity_data.first.to_s),
        dividends: BigDecimal.new(activity_data.last.to_s),
        stock_bundle: bundle
      )
      current_month = current_month.next
    end
  end
  scenario.mutual_funds << vanguard_stock_fund
  scenario.save!
end

end
