require 'rails_helper'

describe ExpenseAccount, :type => :model do

  context 'validations' do

    let(:account) { build(:expense_account) }
    let(:activity) { build(:expense_account_activity, month: account.starting_month) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:starting_amount) }
    it { should validate_numericality_of(:starting_amount) }
    it { should validate_numericality_of(:stdev_coefficient) }

    let(:activity_good) { build(:expense_account_activity, month: activity.month.next) }
    let(:activity_bad) { build(:expense_account_activity, month: activity.month.next.next) }

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
        account.project(account.starting_month)
        expect(account.amount(account.starting_month)).to eq(account.starting_amount)
        current = account.starting_month.next
        1.upto(20) do |i|
          account.project(current)
          expect(account.amount(current)).to eq((account.starting_amount * ((1 + account.rate_of_increase.sample) ** i)).round(2))
          current = current.next
        end
      end

    end

    context 'with random account' do

      let(:account) { build(:expense_account, :with_raise, :with_random_months) }

      it 'should project correct amounts' do
        current = account.starting_month
        0.upto(19) do |i|
          coefficient = account.coefficients[current.month - 1]
          account.project(current)
          expect(account.amount(current)).to eq((coefficient * account.starting_amount * (1 + account.rate_of_increase.sample) ** i).round(2))
          current = current.next
        end
      end

    end

    context 'with multi-annual account' do

      let(:account) { build(:expense_account, :with_raise, :with_year_interval, :with_random_months) }

      it 'should project correct amounts' do
        current = account.starting_month
        0.upto(61) do |i|
          coefficient = account.coefficients[current.month - 1]
          coefficient = 0 if current.year_diff(account.starting_month) % account.year_interval != 0
          account.project(current)
          expect(account.amount(current)).to eq((coefficient * account.starting_amount * (1 + account.rate_of_increase.sample) ** i).round(2))
          current = current.next
        end
      end

    end

    context 'with activity' do

      let(:account) { build(:expense_account, :with_raise) }

      it 'should start inflating after activity' do
        current = account.starting_month
        18.times do   # makes sure it skips a year
          activity = build(:expense_account_activity, month: current)
          account.expense_account_activities << activity
          current = current.next
        end
        account.project(current.prior)
        expect(account.amount(current.prior)).to eq(activity.amount)
        account.project(current)
        expect(account.amount(current)).to eq(account.starting_amount)
        account.project(current.next)
        expect(account.amount(current.next)).to eq((account.starting_amount * (1 + account.rate_of_increase.sample)).round(2))
      end

    end

  end

  context 'with annual rate of increase' do
 
    context 'with basic account' do

      let(:account) { build(:expense_account, :with_raise, :with_annual_raise) }

      it 'should project correct amounts' do
        account.project(account.starting_month)
        expect(account.amount(account.starting_month)).to eq(account.starting_amount)
        current = account.starting_month.next
        1.upto(25) do |i|
          account.project(current)
          rate = (1 + account.rate_of_increase.sample) ** current.year_diff(account.starting_month)
          expect(account.amount(current)).to eq((account.starting_amount * rate).round(2))
          current = current.next
        end
      end

    end

    context 'with multi-annual account' do

      let(:account) { build(:expense_account, :with_raise, :with_annual_raise, :with_year_interval, :with_random_months) }

      it 'should project correct amounts' do
        current = account.starting_month
        0.upto(61) do |i|
          coefficient = account.coefficients[current.month - 1]
          coefficient = 0 if current.year_diff(account.starting_month) % account.year_interval != 0
          rate = (1 + account.rate_of_increase.sample) ** current.year_diff(account.starting_month)
          account.project(current)
          expect(account.amount(current)).to eq((coefficient * account.starting_amount * rate).round(2))
          current = current.next
        end
      end

    end

  end

  context 'with random rate of increase' do

    context 'monthly' do
      let(:account) { build(:expense_account, :with_uncertain_raise) }
      let(:rand_values) { [0.0233, -0.099] }

      before :each do
        allow(account.rate_of_increase).to receive(:sample).and_return(*rand_values)
      end

      it 'should project correct amounts' do
        account.project(account.starting_month)
        expect(account.amount(account.starting_month)).to eq(account.starting_amount)
  
        month = account.starting_month.next
        account.project(month)
        expect(account.amount(month)).to eq((account.starting_amount * (1 + rand_values[0])).round(2))
        month = month.next
        account.project(month)
        expect(account.amount(month)).to eq((account.starting_amount * (1 + rand_values[0]) * (1 + rand_values[1])).round(2))
      end

      it 'should return the same value when called repeatedly' do
        2.times { account.project(account.starting_month) }
        expect(account.amount(account.starting_month)).to eq(account.starting_amount)
        2.times { account.project(account.starting_month.next) }
        expect(account.amount(account.starting_month.next)).to eq((account.starting_amount * (1 + rand_values[0])).round(2))
      end
    end

    context 'yearly' do
      let(:account) { build(:expense_account, :with_uncertain_raise, :with_annual_raise, starting_month: Month.new(2018, 11)) }
      let(:rand_values) { [0.005] }
      it 'should project correct amounts' do
        account.project(account.starting_month)
        expect(account.amount(account.starting_month)).to eq(account.starting_amount)

        allow(account.rate_of_increase).to receive(:sample).and_return(*rand_values)
        month = account.starting_month.next
        account.project(month)
        expect(account.amount(month)).to eq(account.starting_amount)
        month = month.next
        account.project(month)
        expect(account.amount(month)).to eq((account.starting_amount * (1 + rand_values[0])).round(2))
      end
    end

  end

  context 'with random coefficients' do

    let(:account) { build(:expense_account, :with_uncertainty) }
    let(:rand_values) { [45.02, 51.5] }
    it 'should sample from a normal distribution' do
      double = instance_double(RandomVariable)
      allow(double).to receive(:sample).and_return(*rand_values)
      allow(RandomVariable).to receive(:new).with(account.starting_amount, account.stdev_coefficient * account.starting_amount).and_return(double)
      account.project(account.starting_month)
      expect(account.amount(account.starting_month)).to eq(rand_values[0].round(2))

      month = account.starting_month.next
      account.project(month)
      expect(account.amount(month)).to eq(rand_values[1].round(2))
    end

  end

  #TODO All of this should be logic for Expendable
  describe '#transact' do

    let(:scenario) { mock_model(Scenario) }
    let(:account) { build(:expense_account, scenario: scenario) }

    it 'should fail if not projected' do
      expect { account.transact(account.starting_month) }.to raise_error
    end

    context 'with insufficient funds' do
      let(:savings) { instance_double(SavingsAccount) }
      before :each do
        allow(savings).to receive(:running_balance).with(account.starting_month).and_return(0)
        allow(scenario).to receive(:savings_accounts_by_interest_rate).and_return([savings])
      end
      it 'should fail' do
        account.project(account.starting_month)
        expect { account.transact(account.starting_month) }.to raise_error
      end
    end

    context 'with sufficient funds' do
      let(:savings) { instance_double(SavingsAccount) }
      before :each do
        allow(savings).to receive(:running_balance).with(account.starting_month).and_return(account.starting_amount + 50)
        allow(scenario).to receive(:savings_accounts_by_interest_rate).and_return([savings])
      end
      it 'should debit the correct amount' do
        expect(savings).to receive(:debit).with(account.starting_month, account.starting_amount)
        account.project(account.starting_month)
        account.transact(account.starting_month)
      end
    end

    context 'with multiple accounts' do
      let(:savings1) { instance_double(SavingsAccount) }
      let(:savings2) { instance_double(SavingsAccount) }
      let(:savings3) { instance_double(SavingsAccount) }
      before :each do
        allow(savings1).to receive(:running_balance).with(account.starting_month).and_return((account.starting_amount / 3).round(2))
        allow(savings2).to receive(:running_balance).with(account.starting_month).and_return(account.starting_amount * 2)
        allow(savings2).to receive(:running_balance).with(account.starting_month).and_return(account.starting_amount)
        allow(scenario).to receive(:savings_accounts_by_interest_rate).and_return([savings1, savings2, savings3])
      end
      it 'should debit accounts in order' do
        expect(savings1).to receive(:debit).with(account.starting_month, (account.starting_amount / 3).round(2))
        expect(savings2).to receive(:debit).with(account.starting_month, account.starting_amount - (account.starting_amount / 3).round(2))
        account.project(account.starting_month)
        account.transact(account.starting_month)
      end
    end

  end

  describe '#summary' do

    let(:account) { build(:expense_account) }

    it 'should return zero when not projected' do
      expected = {'expenses' => {account.name => {'amount' => 0}, 'TOTAL' => {'amount' => 0}}}
      expect(account.summary(account.starting_month)).to eq(expected)
    end

    it 'should return same as amount when projected' do
      account.project(account.starting_month)
      expected = {'expenses' => {account.name => {'amount' => account.starting_amount}, 'TOTAL' => {'amount' => account.starting_amount}}}
      expect(account.summary(account.starting_month)).to eq(expected)
    end

  end

end

