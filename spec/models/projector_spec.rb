require 'rails_helper'

describe Projector, :type => :model do

  describe '#project' do

    context 'with historicals' do
      let(:scenario) { build(:scenario, :with_historicals) }
      let(:savings_account) { mock_model(SavingsAccount) }
      let(:income_account) { mock_model(IncomeAccount) }
      let(:expense_account) { mock_model(ExpenseAccount) }
      let(:mutual_fund) { mock_model(MutualFund) }
      let(:traditional_401k) { mock_model(Traditional401k) }
      let(:roth_401k) { mock_model(Roth401k) }

      it 'should only project' do
        [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
          expect(account).to receive(:project).with(scenario.starting_month)
          allow(account).to receive(:summary).with(scenario.starting_month).and_return({})
          expect(account).to receive(:summary).with(scenario.starting_month)
          expect(account).to_not receive(:transact)
        end
        scenario.savings_accounts << savings_account
        scenario.income_accounts << income_account
        scenario.expense_accounts << expense_account
        scenario.mutual_funds << mutual_fund
        scenario.traditional401ks << traditional_401k
        scenario.roth401ks << roth_401k
        Projector.new(scenario).project(scenario.starting_month)
      end
    end

    context 'when projecting new data' do
      let(:scenario) { build(:scenario) }
      let(:savings_account) { mock_model(SavingsAccount) }
      let(:income_account) { mock_model(IncomeAccount) }
      let(:expense_account) { mock_model(ExpenseAccount) }
      let(:mutual_fund) { mock_model(MutualFund) }
      let(:traditional_401k) { mock_model(Traditional401k) }
      let(:roth_401k) { mock_model(Roth401k) }

      let(:savings_balance) { BigDecimal.new('500000') }

      before :each do
        [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
          allow(account).to receive(:summary).with(scenario.starting_month).and_return({})
        end
        allow(savings_account).to receive(:start_balance).with(scenario.projections_start).and_return(savings_balance)
        allow(mutual_fund).to receive(:starting_balance).with(scenario.projections_start).and_return(savings_balance * 10)
        scenario.income_accounts << income_account
        scenario.savings_accounts << savings_account
        scenario.expense_accounts << expense_account
        scenario.mutual_funds << mutual_fund
        scenario.traditional401ks << traditional_401k
        scenario.roth401ks << roth_401k
      end

      it 'should project & transact all accounts, buying stock as needed' do
        [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
          expect(account).to receive(:project).with(scenario.starting_month)
          expect(account).to receive(:summary).with(scenario.starting_month)
          expect(account).to receive(:transact)
        end

        current = scenario.projections_start
        6.times do
          allow(expense_account).to receive(:project).with(current)
          allow(expense_account).to receive(:amount).with(current).and_return((savings_balance / 10).round(0))
          current = current.next
        end
        expect(mutual_fund).to receive(:buy).with(scenario.projections_start, savings_balance - (savings_balance * 6 / 10).round(0) - 30000)
        expect(savings_account).to receive(:debit).with(scenario.projections_start, savings_balance - (savings_balance * 6 / 10).round(0) - 30000)
        Projector.new(scenario).project(scenario.projections_start)
      end
 
      it 'should project & transact all accounts, selling stock as needed' do
        [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
          expect(account).to receive(:project).with(scenario.starting_month)
          expect(account).to receive(:summary).with(scenario.starting_month)
          expect(account).to receive(:transact)
        end

        current = scenario.projections_start
        6.times do
          allow(expense_account).to receive(:project).with(current)
          allow(expense_account).to receive(:amount).with(current).and_return((savings_balance / 2).round(0))
          current = current.next
        end
        expect(mutual_fund).to receive(:sell).with(scenario.projections_start, savings_balance * 2)
        expect(savings_account).to receive(:credit).with(scenario.projections_start, savings_balance * 2)
        Projector.new(scenario).project(scenario.projections_start)
      end
    end

  end

  describe '#report' do
    let(:scenario) { build(:scenario, :with_historicals) }
    let(:savings_account) { mock_model(SavingsAccount) }
    let(:income_account) { mock_model(IncomeAccount) }
    let(:expense_account) { mock_model(ExpenseAccount) }
    let(:mutual_fund) { mock_model(MutualFund) }
    let(:traditional_401k) { mock_model(Traditional401k) }
    let(:roth_401k) { mock_model(Roth401k) }

    it 'should aggregate summaries' do
      expected = {}
      [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
        allow(account).to receive(:project).with(scenario.starting_month)
        allow(account).to receive(:summary).with(scenario.starting_month).and_return({
          account.class.to_s => BigDecimal.new(account.class.to_s.length)
        })
        expected[account.class.to_s] = BigDecimal.new(account.class.to_s.length)
      end
      scenario.income_accounts << income_account
      scenario.savings_accounts << savings_account
      scenario.expense_accounts << expense_account
      scenario.mutual_funds << mutual_fund
      scenario.traditional401ks << traditional_401k
      scenario.roth401ks << roth_401k

      projector = Projector.new(scenario)
      projector.project(scenario.starting_month)
      expect(projector.report(scenario.starting_month)).to eq(expected)
    end

  end

end
