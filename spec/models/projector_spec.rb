require 'rails_helper'

describe Scenario, :type => :model do

  let(:scenario) { build(:scenario) }
  let(:savings_account) { build(:savings_account, starting_month: scenario.projections_start) }
  let(:income_account) { build(:income_account, owner: savings_account.owner, starting_month: savings_account.starting_month) }
  let(:expense_account) { build(:expense_account, starting_month: savings_account.starting_month, starting_amount: savings_account.starting_balance / 2) }
  let(:mutual_fund) { build(:mutual_fund, starting_month: scenario.projections_start) }

  it 'should run accounts in order' do
    month = scenario.projections_start
    scenario.income_accounts << income_account
    scenario.savings_accounts << savings_account
    scenario.expense_accounts << expense_account
    scenario.mutual_funds << mutual_fund
    report = Projector.new(scenario).project(month)[month]
    expect(report[:gross_income]).to eq(income_account.gross(month))
    expect(report[:interest]).to eq(savings_account.interest(month))
    expect(report[:savings_balance]).to eq(savings_account.ending_balance(month))
    expect(report[:expenses]).to eq(expense_account.amount(month))
  end

  context 'with more than one account' do

    let(:savings_account2) { build(:savings_account, starting_month: savings_account.starting_month) }
    let(:income_account2) { build(:income_account, owner: savings_account2.owner, starting_month: savings_account.starting_month) }
    let(:expense_account2) { build(:expense_account, starting_month: savings_account.starting_month, starting_amount: savings_account.starting_balance / 4) }

    it 'should run sums of account info' do
      month = savings_account.starting_month
      scenario.income_accounts += [income_account, income_account2]
      scenario.savings_accounts += [savings_account, savings_account2]
      scenario.expense_accounts += [expense_account, expense_account2]
      report = Projector.new(scenario).project(month)[month]
      expect(report[:gross_income]).to eq(income_account.gross(month) + income_account2.gross(month))
      expect(report[:interest]).to eq(savings_account.interest(month) + savings_account2.interest(month))
      expect(report[:savings_balance]).to eq(savings_account.ending_balance(month) + savings_account2.ending_balance(month))
      expect(report[:expenses]).to eq(expense_account.amount(month) + expense_account2.amount(month))
    end

  end

end
