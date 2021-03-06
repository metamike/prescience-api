require 'rails_helper'

describe SavingsAccount, :type => :model do

  context 'validations' do

    it { should validate_presence_of(:monthly_interest_rate) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:starting_balance) }
    it { should validate_numericality_of(:starting_balance) }

    let(:account) { build(:savings_account) }

    it 'should validate starting_balance when there is no activity' do
      account.starting_balance = nil
      expect(account.valid?).to be(false)
    end

    context 'with activity' do
      let(:activity) { build(:savings_account_activity, month: account.starting_month) }

      it 'should not validate starting_balance' do
        account.starting_balance = nil
        account.savings_account_activities << activity
        expect(account.valid?).to be(true)
      end

      context 'with even more activities' do
        let(:activity_bad) { build(:savings_account_activity, month: activity.month.next.next) }
        let(:activity_good) { build(:savings_account_activity, month: activity.month.next) }

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
  let(:activity) { build(:savings_account_activity, month: account.starting_month) }
  let(:credit) { Faker::Number.number(6).to_i / 100.0 }
  let(:debit) { Faker::Number.number(5).to_i / 100.0 }

  it 'should return zeroes when requesting a date before the present' do
    month = account.starting_month.prior
    account.project(month)
    expect(account.interest(month)).to eq(0)
    expect(account.ending_balance(month)).to eq(0)
  end

  it 'should use historicals if present w/o requiring projection' do
    account.savings_account_activities << activity
    expect(account.interest(activity.month)).to eq(activity.interest)
    expect(account.ending_balance(activity.month)).to eq(activity.ending_balance)
  end

  it 'should calculate the next month' do
    account.savings_account_activities << activity
    month = activity.month.next
    account.project(month)
    expect(account.interest(month)).to eq((activity.ending_balance * account.monthly_interest_rate.sample).round(2))
    expect(account.ending_balance(month)).to eq(activity.ending_balance + account.interest(month))
  end

  it 'should calculate two months ahead' do
    account.savings_account_activities << activity
    account.project(activity.month.next)
    month = activity.month.next.next
    account.project(month)
    expect(account.interest(month)).to eq(((activity.ending_balance * (1 + account.monthly_interest_rate.sample)) * account.monthly_interest_rate.sample).round(2))
    expect(account.ending_balance(month)).to eq(account.ending_balance(activity.month.next) + account.interest(month))
  end

  it 'should respect credits and debits' do
    account.credit(account.starting_month, credit)
    account.debit(account.starting_month, debit)
    account.project(account.starting_month)
    expect(account.interest(account.starting_month)).to eq(
      ((account.starting_balance + credit - debit) * account.monthly_interest_rate.sample).round(2)
    )
    expect(account.ending_balance(account.starting_month)).to eq(
      account.starting_balance + credit - debit + account.interest(account.starting_month)
    )
  end

  context 'with uncertain interest' do

    let(:account) { build(:savings_account, :uncertain_interest) }

    context 'and positive interest' do
      let(:rand_values) { [0.0007575949881074517] }
      it 'should calculate interest correctly' do
        allow(account.monthly_interest_rate).to receive(:sample).and_return(*rand_values)
        account.project(account.starting_month)
        expect(account.interest(account.starting_month)).to eq(
          (account.starting_balance * rand_values[0]).round(2)
        )
        expect(account.ending_balance(account.starting_month)).to eq(
          (account.starting_balance * (1 + rand_values[0])).round(2)
        )
      end
    end

    context 'and a negative random number' do
      let(:rand_values) { [-1] }
      it 'should not decrease savings' do
        allow(account.monthly_interest_rate).to receive(:sample).and_return(*rand_values)
        account.project(account.starting_month)
        expect(account.interest(account.starting_month)).to eq(0)
        expect(account.ending_balance(account.starting_month)).to eq(account.starting_balance)
      end
    end

  end

  describe '#running_balance' do
    let(:account) { build(:savings_account) }
    let(:credit) { 1000 }
    let(:debit) { 200 }
    it 'should respect credits and debits' do
      2.times { account.credit(account.starting_month, credit) }
      3.times { account.debit(account.starting_month, debit) }
      expect(account.running_balance(account.starting_month)).to eq(account.starting_balance + 2 * credit - 3 * debit)
    end
  end

  describe '#transact' do
    let(:account) { build(:savings_account) }
    it 'should not fail' do
      expect { account.transact(account.starting_month) }.to_not raise_error
    end
  end

  describe '#summary' do

    let(:account) { build(:savings_account) }

    it 'should return zero when not projected' do
      expected = {'savings' => {'starting balance' => account.starting_balance, 'interest' => 0, 'ending balance' => 0}}
      expect(account.summary(account.starting_month)).to eq(expected)
    end

    it 'should summarize interest and ending balance' do
      account.project(account.starting_month)
      expected = {'savings' => {
        'starting balance' => account.start_balance(account.starting_month),
        'interest' => account.interest(account.starting_month),
        'ending balance' => account.ending_balance(account.starting_month)
      }}
      expect(account.summary(account.starting_month)).to eq(expected)
    end

  end

end

