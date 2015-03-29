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
    social_security_wage_limit: BigDecimal.new('118500'),
    social_security_wage_limit_growth_rate: RandomVariable.new(0.022, 0.015),
    state_disability_wage_limit: BigDecimal.new('104378'),
    state_disability_wage_limit_growth_rate: RandomVariable.new(0.019, 0.1),
    annual_401k_contribution_limit: BigDecimal.new('18000'),
    annual_401k_contribution_limit_growth_rate: RandomVariable.new(0.03, 0.01)
    # annual IRA contribition: 5500  (0.027, 0.01)
  )
  scenario.tax_info = tax_info
  scenario.save!
end

# Owners
mike = Owner.find_by_name('Mike') || Owner.create!(name: 'Mike')
robin = Owner.find_by_name('Robin') || Owner.create!(name: 'Robin')

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
    loan_term_months: 360
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
