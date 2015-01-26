require 'rails_helper'

describe SavingsAccount, :type => :model do

  context 'validations' do

    it { should validate_presence_of(:interest_rate) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:starting_balance) }
    it { should validate_numericality_of(:starting_balance) }

    let(:account) { build(:savings_account) }

    it 'should validate starting_balance when there is no activity' do
      account.starting_balance = nil
      expect(account.valid?).to be(false)
    end

    context 'with activity' do
      let(:activity) { build(:savings_account_activity, month: account.starting_month, savings_account: account) }

      it 'should not validate starting_balance' do
        account.starting_balance = nil
        account.savings_account_activities << activity
        expect(account.valid?).to be(true)
      end

      context 'with even more activities' do
        let(:activity_bad) { build(:savings_account_activity, month: activity.month.next.next, savings_account: account) }
        let(:activity_good) { build(:savings_account_activity, month: activity.month.next, savings_account: account) }

        it 'should fail if activities are out of order' do
          account.savings_account_activities << activity
          account.savings_account_activities << activity_bad
          expect(account.valid?).to be(false)
        end
        
        it 'should validate that activities are in order' do
          account.savings_account_activities << activity
          account.savings_account_activities << activity_good
          expect(account.valid?).to be(true)
        end
      end
    end

  end

  let(:account) { build(:savings_account) }
  let(:activity) { build(:savings_account_activity, month: account.starting_month, savings_account: account) }

  it 'should fails when requesting a date before the present' do
    expect { account.project(savings_account.starting_month.prior) }.to raise_error
  end

  it 'should use historicals if present' do
    account.savings_account_activities << activity
    account.project(activity.month)
    expect(account.interest(activity.month)).to eq(activity.interest)
    expect(account.ending_balance(activity.month)).to eq(activity.ending_balance)
  end

  it 'should calculate the next month' do
    account.savings_account_activities << activity
    account.project(activity.month)
    month = activity.month.next
    account.project(month)
    expect(account.interest(month)).to eq(activity.ending_balance * account.interest_rate)
    expect(account.ending_balance(month)).to eq(activity.ending_balance + account.interest(month))
  end

  it 'should calculate two months ahead' do
    account.savings_account_activities << activity
    account.project(activity.month)
    account.project(activity.month.next)
    month = activity.month.next.next
    account.project(month)
    expect(account.interest(month)).to eq((activity.ending_balance * (1 + account.interest_rate)) * account.interest_rate)
    expect(account.ending_balance(month)).to eq(account.ending_balance(activity.month.next) + account.interest(month))
  end

end

