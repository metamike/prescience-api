require 'rails_helper'

describe ExpenseAccount, :type => :model do

  context 'validations' do

    let(:account) { build(:expense_account) }
    let(:activity) { build(:expense_account_activity, month: account.starting_month, expense_account: account) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:starting_amount) }
    it { should validate_numericality_of(:starting_amount) }

    let(:activity_good) { build(:expense_account_activity, month: activity.month.next, expense_account: account) }
    let(:activity_bad) { build(:expense_account_activity, month: activity.month.next.next, expense_account: account) }

    it 'should fail if activities are out of order' do
      account.expense_account_activities << activity
      expect(account.valid?).to be(true)
      account.expense_account_activities << activity_bad
      expect(account.valid?).to be(false)
    end

    it 'should validate that activities are in order' do
      account.expense_account_activities << activity
      account.expense_account_activities << activity_good
      expect(account.valid?).to be(true)
    end
  end

  let(:account) { build(:expense_account) }
  let(:activity) { build(:expense_account_activity, month: account.starting_month) }

  it 'should return a default value for a non-projected month' do
    expect(account.amount(account.starting_month.next)).to eq(0)
  end

  it 'should use activity if present' do
    account.expense_account_activities << activity
    account.project(activity.month)
    expect(account.amount(activity.month)).to eq(activity.amount)
  end

  context 'with monthly rate of increase' do

    context 'with basic account' do

      let(:account) { build(:expense_account, :with_raise) }

      it 'should project correct amounts' do
        allow(account).to receive(:transact)
        account.project(account.starting_month)
        expect(account.amount(account.starting_month)).to eq(account.starting_amount)
        current = account.starting_month.next
        1.upto(20) do |i|
          account.project(current)
          expect(account.amount(current)).to eq(account.starting_amount * ((1 + account.rate_of_increase) ** i))
          current = current.next
        end
      end

    end

    context 'with random account' do

      let(:account) { build(:expense_account, :with_raise, :with_random_months) }

      it 'should project correct amounts' do
        allow(account).to receive(:transact)
        current = account.starting_month
        0.upto(19) do |i|
          coefficient = account.coefficients[current.month - 1]
          account.project(current)
          expect(account.amount(current)).to eq(coefficient * account.starting_amount * (1 + account.rate_of_increase) ** i)
          current = current.next
        end
      end

    end

    context 'with multi-annual account' do

      let(:account) { build(:expense_account, :with_raise, :with_year_interval, :with_random_months) }

      it 'should project correct amounts' do
        allow(account).to receive(:transact)
        current = account.starting_month
        0.upto(61) do |i|
          coefficient = account.coefficients[current.month - 1]
          coefficient = 0 if current.year_diff(account.starting_month) % account.year_interval != 0
          account.project(current)
          expect(account.amount(current)).to eq(coefficient * account.starting_amount * (1 + account.rate_of_increase) ** i)
          current = current.next
        end
      end

    end

    context 'with activity' do

      let(:account) { build(:expense_account, :with_raise) }

      it 'should start inflating after activity' do
        allow(account).to receive(:transact)
        current = account.starting_month
        18.times do   # makes sure it skips a year
          activity = build(:expense_account_activity, month: current)
          account.expense_account_activities << activity
          current = current.next
        end
        account.project(current.prior)
        expect(account.amount(current.prior)).to eq(activity.amount)
        account.project(current)
        expect(account.amount(current)).to eq(account.starting_amount * (1 + account.rate_of_increase))
      end

    end

  end

  context 'with annual rate of increase' do
 
    context 'with basic account' do

      let(:account) { build(:expense_account, :with_annual_raise) }

      it 'should project correct amounts' do
        allow(account).to receive(:transact)
        account.project(account.starting_month)
        expect(account.amount(account.starting_month)).to eq(account.starting_amount)
        current = account.starting_month.next
        1.upto(25) do |i|
          account.project(current)
          rate = (1 + account.rate_of_increase) ** current.year_diff(account.starting_month)
          expect(account.amount(current)).to eq(account.starting_amount * rate)
          current = current.next
        end
      end

    end

    context 'with multi-annual account' do

      let(:account) { build(:expense_account, :with_annual_raise, :with_year_interval, :with_random_months) }

      it 'should project correct amounts' do
        allow(account).to receive(:transact)
        current = account.starting_month
        0.upto(61) do |i|
          coefficient = account.coefficients[current.month - 1]
          coefficient = 0 if current.year_diff(account.starting_month) % account.year_interval != 0
          rate = (1 + account.rate_of_increase) ** current.year_diff(account.starting_month)
          account.project(current)
          expect(account.amount(current)).to eq(coefficient * account.starting_amount * rate)
          current = current.next
        end
      end

    end

  end

  context '#transact' do

    let(:account) { build(:expense_account, starting_amount: BigDecimal.new('50')) }
    let(:low_account) { build(:savings_account, starting_balance: account.starting_amount - 1) }
    let(:high_account) { build(:savings_account, starting_balance: account.starting_amount + 1) }

    it 'should fail when there are insufficient funds' do
      low_account.project(account.starting_month)
      account.scenario.savings_accounts << low_account
      expect { account.project(account.starting_month) }.to raise_error
    end

    it 'should proceed when there are sufficient funds' do
      high_account.project(account.starting_month)
      account.scenario.savings_accounts << high_account
      expect(high_account).to receive(:debit)
      account.project(account.starting_month)
    end

  end

end

