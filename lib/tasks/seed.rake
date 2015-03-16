# Scenarios
scenario = Scenario.find_by_name('ROOT')
unless scenario
  scenario = Scenario.create!(
    name: 'ROOT',
    starting_month: Month.new(2014, 1),
    projections_start: Month.new(2015, 2)
  )
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
    starting_amount: BigDecimal.new('8000'),
    rate_of_increase: RandomVariable.new(0.03/12, 0.02/12),
    stdev_coefficient: 0.1
  )
  scenario.expense_accounts << expenses
  scenario.save!
end

# Mutual Funds
unless MutualFund.find_by_name('Vanguard Stock Fund')
  vanguard_stock_fund = MutualFund.create!(
    name: 'Vanguard Stock Fund',
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

