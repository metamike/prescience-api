require 'rails_helper'

describe IncomeAccount, :type => :model do

  # let(:savings) { mock_model(SavingsAccount, :[]= => nil) }
  let(:account) { build(:income_account) }
  let(:activity) { build(:income_account_activity, month: account.starting_month) }

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:annual_salary) }
    it { should validate_numericality_of(:annual_salary) }
    it { should validate_presence_of(:owner) }

    let(:activity_good) { build(:income_account_activity, month: activity.month.next) }
    let(:activity_bad) { build(:income_account_activity, month: activity.month.next.next) }

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

  it 'should return a default value for a non-projected month' do
    expect(account.gross(account.starting_month.next)).to eq(0)
  end

  it 'should use activity if present' do
    account.income_account_activities << activity
    account.project(activity.month)
    expect(account.gross(activity.month)).to eq(activity.gross)
  end

  it 'should calculate when it has no activity' do
    account.project(account.starting_month)
    expect(account.gross(account.starting_month)).to eq((account.annual_salary / 12.0).round(2))
  end

  context 'with annual raise' do

    let(:account) { build(:income_account, :with_raise) }

    it 'should account for an annual raise' do
      current = account.starting_month
      0.upto(24) do |i|
        account.project(current)
        rate = (1 + account.annual_raise.mean) ** current.year_diff(account.starting_month)
        expect(account.gross(current)).to eq((account.annual_salary * rate / 12.0).round(2))
        current = current.next
      end
    end

    it 'should begin the raise process only after historicals' do
      current = account.starting_month
      18.times do   # makes sure it skips a year
        activity = build(:income_account_activity, month: current)
        account.income_account_activities << activity
        current = current.next
      end
      account.project(current)
      expect(account.gross(current)).to eq((account.annual_salary / 12.0).round(2))
      loop do
        current = current.next
        account.project(current)
        break if current.year != account.income_account_activities.last.month.year
      end
      expect(account.gross(current)).to eq((account.annual_salary * (1 + account.annual_raise.mean) / 12.0).round(2))
    end

  end

  context 'with uncertain raise' do

    let(:account) { build(:income_account, :uncertain_raise, starting_month: Month.new(2014, 12)) }
    let(:rand_values) { [0.0007575949881074517, -0.0001] }

    it 'should sample from a normal distribution to determine raises' do
      allow(account.annual_raise).to receive(:sample).and_return(*rand_values)
      month = account.starting_month
      account.project(month)
      expect(account.gross(month)).to eq((account.annual_salary / 12.0).round(2))
      month = month.next
      account.project(month)
      expect(account.gross(month)).to eq(((1 + rand_values[0]) * account.annual_salary / 12.0).round(2))
    end

  end

  describe '#transact' do

    let(:scenario) { mock_model(Scenario) }
    let(:account) { build(:income_account, scenario: scenario) }
    let(:savings) { instance_double(SavingsAccount) }

    before :each do
      allow(savings).to receive(:credit)
    end

    context 'when called before projecting' do
      it 'should fail' do
        allow(scenario).to receive(:savings_account_by_owner).and_return(savings)
        expect { account.transact(account.starting_month) }.to raise_error
      end
    end

    context 'with no savings account' do
      it 'should fail' do
        allow(scenario).to receive(:savings_account_by_owner).and_return(nil)
        account.project(account.starting_month)
        expect { account.transact(account.starting_month) }.to raise_error
      end
    end

    context 'with a savings account' do
      it 'should credit the savings account' do
        allow(scenario).to receive(:savings_account_by_owner).with(account.owner).and_return(savings)
        account.project(account.starting_month)
        expect(savings).to receive(:credit).with(account.starting_month, account.gross(account.starting_month))
        account.transact(account.starting_month)
      end
    end

  end

end

