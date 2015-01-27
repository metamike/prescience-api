require 'rails_helper'

describe Scenario, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  let(:savings_account) { build(:savings_account) }
  let(:income_account) { build(:income_account, savings_account: savings_account, starting_month: savings_account.starting_month) }
  let(:scenario) { build(:scenario) }

  it 'should run income accounts first and then savings accounts' do
    month = savings_account.starting_month
    scenario.income_accounts << income_account
    scenario.savings_accounts << savings_account
    report = scenario.project(month)
    expect(report[:gross_income]).to eq(income_account.gross(month))
    expect(report[:interest]).to eq(savings_account.interest(month))
    expect(report[:savings_balance]).to eq(savings_account.ending_balance(month))
  end

  context 'with more than one account' do

    let(:savings_account2) { build(:savings_account, starting_month: savings_account.starting_month) }
    let(:income_account2) { build(:income_account, savings_account: savings_account2, starting_month: savings_account.starting_month) }

    it 'should run sums of account info' do
      month = savings_account.starting_month
      scenario.income_accounts += [income_account, income_account2]
      scenario.savings_accounts += [savings_account, savings_account2]
      report = scenario.project(month)
      expect(report[:gross_income]).to eq(income_account.gross(month) + income_account2.gross(month))
      expect(report[:interest]).to eq(savings_account.interest(month) + savings_account2.interest(month))
      expect(report[:savings_balance]).to eq(savings_account.ending_balance(month) + savings_account2.ending_balance(month))
    end

  end

end
