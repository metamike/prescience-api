require 'rails_helper'

describe IncomeAccount, :type => :model do

  let(:account) { build(:income_account) }
  let(:activity) { build(:income_account_activity, month: account.starting_month, income_account: account) }

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:annual_gross) }
    it { should validate_numericality_of(:annual_gross) }

    let(:activity_good) { build(:income_account_activity, month: activity.month.next, income_account: account) }
    let(:activity_bad) { build(:income_account_activity, month: activity.month.next.next, income_account: account) }

    it 'should fail if activities are out of order' do
      account.income_account_activities << activity
      expect(account.valid?).to be(true)
      account.income_account_activities << activity_bad
      expect(account.valid?).to be(false)
    end

    it 'should validate that activities are in order' do
      account.income_account_activities << activity
      account.income_account_activities << activity_good
      expect(account.valid?).to be(true)
    end
  end

  it 'should use activity if present' do
    account.income_account_activities << activity
    account.project(activity.month)
    expect(account.gross(activity.month)).to eq(activity.gross)
    account.savings_account.project(activity.month)
    expect(account.savings_account.interest(activity.month)).to eq(
      (account.savings_account.starting_balance + activity.gross) * account.savings_account.interest_rate
    )
    expect(account.savings_account.ending_balance(activity.month)).to eq(
      account.savings_account.starting_balance + activity.gross + account.savings_account.interest(activity.month)
    )
  end

  it 'should calculate when it has no activity' do
    account.project(account.starting_month)
    expect(account.gross(account.starting_month)).to eq(account.annual_gross / 12.0)
    account.savings_account.project(account.starting_month)
    expect(account.savings_account.interest(account.starting_month)).to eq(
      (account.savings_account.starting_balance + account.annual_gross / 12.0) * account.savings_account.interest_rate
    )
    expect(account.savings_account.ending_balance(account.starting_month)).to eq(
      account.savings_account.starting_balance + account.annual_gross / 12.0 + account.savings_account.interest(account.starting_month)
    )
  end

end

