require 'rails_helper'

describe 'Prescience Backend' do

  let(:savings_account_activity_low) { build(:savings_account_activity, :for_summary_low) }
  let(:savings_account_low) { build(:savings_account, :for_summary_low) }
  let(:savings_account_activity_high) { build(:savings_account_activity, :for_summary_high) }
  let(:savings_account_high) { build(:savings_account, :for_summary_high) }

  let(:income_account_activity_low) { build(:income_account_activity, :for_summary_low) }
  let(:income_account_low) { build(:income_account, :for_summary_low, savings_account: savings_account_low) }
  let(:income_account_activity_high) { build(:income_account_activity, :for_summary_high) }
  let(:income_account_high) { build(:income_account, :for_summary_high, savings_account: savings_account_high) }

  let(:groceries_activity) { build(:expense_account_activity, :for_summary_groceries) }
  let(:groceries) { build(:expense_account, :for_summary_groceries) }
  let(:entertainment_activity) { build(:expense_account_activity, :for_summary_entertainment) }
  let(:entertainment) { build(:expense_account, :for_summary_entertainment) }

  let(:scenario) { build(:scenario) }

  it 'should generate actuals' do
    savings_account_low.savings_account_activities << savings_account_activity_low
    savings_account_high.savings_account_activities << savings_account_activity_high
    scenario.savings_accounts += [savings_account_low, savings_account_high]
    income_account_low.income_account_activities << income_account_activity_low
    income_account_high.income_account_activities << income_account_activity_high
    scenario.income_accounts += [income_account_low, income_account_high]
    groceries.expense_account_activities << groceries_activity
    entertainment.expense_account_activities << entertainment_activity
    scenario.expense_accounts += [groceries, entertainment]
    month = Month.new(2014, 1)
    scenario.project(month)
    report = scenario.report
    expect(report.length).to eq(1)
    expect(report[month]).to eq({
      gross_income:    BigDecimal.new('22833.33'),
      interest:        BigDecimal.new('2.66'),
      savings_balance: BigDecimal.new('59020.80'),
      expenses:        BigDecimal.new('1211.50')
    })
 end

end

