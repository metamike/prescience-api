require 'rails_helper'

describe 'Prescience Backend' do

  let(:savings_account_activity_low) { build(:savings_account_activity, :for_summary_low) }
  let(:savings_account_low) { build(:savings_account, :for_summary_low) }
  let(:savings_account_activity_high) { build(:savings_account_activity, :for_summary_high) }
  let(:savings_account_high) { build(:savings_account, :for_summary_high) }

  let(:income_account_activity_low) { build(:income_account_activity, :for_summary_low) }
  let(:income_account_low) { build(:income_account, :for_summary_low, owner: savings_account_low.owner) }
  let(:income_account_activity_high) { build(:income_account_activity, :for_summary_high) }
  let(:income_account_high) { build(:income_account, :for_summary_high, owner: savings_account_high.owner) }

  let(:groceries_activity) { build(:expense_account_activity, :for_summary_groceries) }
  let(:groceries) { build(:expense_account, :for_summary_groceries) }
  let(:entertainment_activity) { build(:expense_account_activity, :for_summary_entertainment) }
  let(:entertainment) { build(:expense_account, :for_summary_entertainment) }

  let(:scenario) { create(:scenario) }

  it 'should generate actuals' do
    scenario.projections_start = Month.new(2014, 1)
    savings_account_low.savings_account_activities << savings_account_activity_low
    savings_account_high.savings_account_activities << savings_account_activity_high
    scenario.savings_accounts += [savings_account_low, savings_account_high]
    income_account_low.income_account_activities << income_account_activity_low
    income_account_high.income_account_activities << income_account_activity_high
    scenario.income_accounts += [income_account_low, income_account_high]
    groceries.expense_account_activities << groceries_activity
    entertainment.expense_account_activities << entertainment_activity
    scenario.expense_accounts += [groceries, entertainment]
    expectation_data = [
      [22833.33, 1211.50, 59020.80, 2.66],
      [23333.33, 1280.00, 81078.53, 4.40],
      [23333.33, 1283.00, 103134.50, 5.64],
      [23333.33, 1286.01, 125188.70, 6.88],
      [23333.33, 1289.02, 147241.14, 8.13],
      [23333.33, 1292.05, 169291.79, 9.37],
      [23333.33, 1295.08, 191340.65, 10.61],
      [23333.33, 1298.11, 213387.72, 11.85],
      [23333.33, 1301.16, 235432.98, 13.09],
      [23333.33, 1304.21, 257476.43, 14.33],
      [23333.33, 1307.27, 279518.06, 15.57],
      [23333.33, 1310.34, 301557.87, 16.82],
      [24056.67, 1313.42, 324319.22, 18.10]
    ]
    expectation = {}
    current = scenario.projections_start
    expectation_data.each do |row|
      expectation[current] = {
        gross_income:      BigDecimal.new(row[0].to_s),
        interest:          BigDecimal.new(row[3].to_s),
        savings_balance:   BigDecimal.new(row[2].to_s),
        expenses:          BigDecimal.new(row[1].to_s),
        stock_performance: BigDecimal.new('0'),
        stock_balance:     BigDecimal.new('0')
      }
      current = current.next
    end
    projector = Projector.new(scenario)
    projector.project(Month.new(2015, 1))
    current = scenario.projections_start
    loop do
      expect(projector.report[current]).to eq(expectation[current])
      current = current.next
      break if current == Month.new(2015, 2)
    end
 end

end

