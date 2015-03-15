require 'rails_helper'

describe Scenario, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:projections_start) }
    it { should validate_presence_of(:starting_month) }
  end

  let(:scenario) { build(:scenario) }

  describe '#savings_account_by_owner' do
    let(:owner) { build(:owner) }

    context 'with no accounts' do
      it 'should return nil' do
        expect(scenario.savings_account_by_owner(owner)).to be_nil
      end
    end

    context 'with accounts' do
      let(:savings1) { build(:savings_account) }
      let(:savings2) { build(:savings_account, owner: owner) }

      before :each do
        scenario.savings_accounts += [savings1, savings2]
      end

      it 'should return nil when no owner is passed' do
        expect(scenario.savings_account_by_owner(nil)).to be_nil
      end

      it 'should return the correct account by owner' do
        expect(scenario.savings_account_by_owner(owner)).to eq(savings2)
      end
    end

  end

  describe '#savings_accouts_by_interest_rate' do

    context 'with no accounts' do
      it 'should be empty' do
        expect(scenario.savings_accounts_by_interest_rate).to be_empty
      end
    end

    context 'with multiple accounts' do
      let(:savings1) { build(:savings_account) }
      let(:savings2) { build(:savings_account, monthly_interest_rate: build(:random_variable, mean: savings1.monthly_interest_rate.mean / 4, stdev: 0)) }
      let(:savings3) { build(:savings_account, monthly_interest_rate: build(:random_variable, mean: savings1.monthly_interest_rate.mean / 2, stdev: 0)) }

      before :each do
        scenario.savings_accounts += [savings1, savings2, savings3]
      end

      it 'should return in order' do
        expect(scenario.savings_accounts_by_interest_rate).to eq([savings2, savings3, savings1])
      end
    end

  end

end
