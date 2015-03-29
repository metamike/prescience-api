require 'rails_helper'

describe Scenario, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:projections_start) }
    it { should validate_presence_of(:starting_month) }

    let(:scenario) { build(:scenario) }
    let(:traditional_401k) { mock_model(Traditional401k) }
    let(:roth_401k) { mock_model(Roth401k) }
    let(:owner) { instance_double(Owner) }

    before :each do
      [traditional_401k, roth_401k].each do |account|
        allow(account).to receive(:owner).and_return(owner)
        allow(account).to receive(:active?).and_return(true)
      end
    end

    context 'when there are no active 401ks' do
      it 'should be valid' do
        expect(scenario.valid?).to be(true)
      end
    end

    context 'when there is one of each active account by owner' do
      it 'should be valid' do
        scenario.traditional401ks << traditional_401k
        scenario.roth401ks << roth_401k
        expect(scenario.valid?).to be(true)
      end
    end

    context 'when there is more than one type of 401k' do
      it 'should not be valid with more than one traditional 401k' do
        scenario.traditional401ks += [traditional_401k, traditional_401k]
        expect(scenario.valid?).to be(false)
      end
      it 'should not be valid with more than one roth 401k' do
        scenario.roth401ks += [roth_401k, roth_401k]
        expect(scenario.valid?).to be(false)
      end
    end
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

  describe '#active_401ks_by_owner' do

    let(:owner) { instance_double(Owner) }
    let(:owner2) { instance_double(Owner) }

    context 'with no active accounts' do
      it 'should be empty' do
        expect(scenario.active_401ks_by_owner(owner)).to be_empty
      end
    end

    context 'with multiple accounts' do
      [:acct1, :acct2, :acct3].each do |account|
        let(account) { mock_model(Traditional401k) }
      end
      [:acctx, :accty, :acctz].each do |account|
        let(account) { mock_model(Roth401k) }
      end
      it 'should only return active accounts by owner' do
        [acct1, acct2, acctx, accty].each do |account|
          allow(account).to receive(:owner).and_return(owner)
        end
        [acct3, acctz].each do |account|
          allow(account).to receive(:owner).and_return(owner2)
        end
        [acct2, acct3, accty, acctz].each do |account|
          allow(account).to receive(:active?).and_return(true)
        end
        [acct1, acctx].each do |account|
          allow(account).to receive(:active?).and_return(false)
        end
        scenario.traditional401ks += [acct1, acct2, acct3]
        scenario.roth401ks += [acctx, accty, acctz]
        accounts = scenario.active_401ks_by_owner(owner)
        expect(accounts.length).to eq(2)
        expect(accounts).to include(acct2)
        expect(accounts).to include(accty)
      end
    end
  end

  describe '#commuter_account_by_owner' do
    let(:owner) { instance_double(Owner) }
    let(:owner2) { instance_double(Owner) }
    let(:expense_account) { mock_model(ExpenseAccount) }

    before :each do
      allow(expense_account).to receive(:owner)
      scenario.expense_accounts << expense_account
    end

    context 'with no accounts' do
      it 'should return nil' do
        expect(scenario.commuter_account_by_owner(owner)).to be_nil
      end
    end

    context 'with accounts' do
      let(:commuter) { mock_model(ExpenseAccount) }
      let(:commuter2) { mock_model(ExpenseAccount) }
      it 'should return the owner''s commuter account' do
        [commuter, commuter2].each do |account|
          allow(account).to receive(:name).and_return('Commuter')
        end
        allow(commuter).to receive(:owner).and_return(owner)
        allow(commuter2).to receive(:owner).and_return(owner2)
        scenario.expense_accounts += [commuter, commuter2]
        expect(scenario.commuter_account_by_owner(owner)).to eq(commuter)
      end
    end

  end

end
