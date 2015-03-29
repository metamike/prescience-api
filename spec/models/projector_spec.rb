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
      let(:owner) { instance_double(Owner) }
      let(:income_account) { mock_model(IncomeAccount) }
      let(:expense_account) { mock_model(ExpenseAccount) }
      let(:mutual_fund) { mock_model(MutualFund) }
      let(:traditional_401k) { mock_model(Traditional401k) }
      let(:roth_401k) { mock_model(Roth401k) }
      let(:tax_info) { mock_model(TaxInfo, :[]= => nil) }

      let(:savings_balance) { BigDecimal.new('500000') }

      before :each do
        [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
          allow(account).to receive(:summary).with(scenario.starting_month).and_return({})
        end
        allow(savings_account).to receive(:running_balance).with(scenario.projections_start).and_return(savings_balance)
        allow(mutual_fund).to receive(:starting_balance).with(scenario.projections_start).and_return(savings_balance * 10)
        allow(income_account).to receive(:owner).and_return(owner)
        allow(income_account).to receive(:ytd_401k_contributions).with(scenario.starting_month).and_return(0)
        allow(scenario).to receive(:active_401ks_by_owner).with(owner).and_return([traditional_401k, roth_401k])
        allow(tax_info).to receive(:annual_401k_contribution_limit_for_year).with(scenario.starting_month.year).and_return(0)
        scenario.tax_info = tax_info
        scenario.income_accounts << income_account
        scenario.savings_accounts << savings_account
        scenario.expense_accounts << expense_account
        scenario.mutual_funds << mutual_fund
        scenario.traditional401ks << traditional_401k
        scenario.roth401ks << roth_401k
      end

      context 'with 401(k)s' do
        it 'should contribute up to the limit when no contributions have been made' do
          [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
            allow(account).to receive(:project)
            allow(account).to receive(:summary)
            allow(account).to receive(:transact)
          end

          contribution_limit = (savings_balance / 10).round(2)
          allow(tax_info).to receive(:annual_401k_contribution_limit_for_year).with(scenario.starting_month.year).and_return(contribution_limit)
          allow(expense_account).to receive(:project)
          allow(expense_account).to receive(:amount).and_return(0)
          contribution = ((contribution_limit / (12 - scenario.projections_start.month + 1)) / 2).round(2)
          expect(traditional_401k).to receive(:buy).with(scenario.projections_start, contribution)
          expect(roth_401k).to receive(:buy).with(scenario.projections_start, contribution)
          expect(income_account).to receive(:record_pretax_401k_contribution).with(scenario.projections_start, contribution)
          expect(income_account).to receive(:record_aftertax_401k_contribution).with(scenario.projections_start, contribution)

          expect(mutual_fund).to receive(:buy).with(scenario.projections_start, savings_balance - contribution * 2 - Projector::MINIMUM_SAVINGS)
          expect(savings_account).to receive(:debit).with(scenario.projections_start, savings_balance - contribution * 2 - Projector::MINIMUM_SAVINGS)
          Projector.new(scenario).project(scenario.projections_start)
        end

        it 'should contribute up to the available amount and not buy mutual funds' do
          [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
            allow(account).to receive(:project)
            allow(account).to receive(:summary)
            allow(account).to receive(:transact)
          end

          contribution_limit = savings_balance * 10
          allow(tax_info).to receive(:annual_401k_contribution_limit_for_year).with(scenario.starting_month.year).and_return(contribution_limit)
          allow(expense_account).to receive(:project)
          allow(expense_account).to receive(:amount).and_return(0)
          contribution = ((savings_balance - Projector::MINIMUM_SAVINGS) / 2).round(2)
          expect(traditional_401k).to receive(:buy).with(scenario.projections_start, contribution)
          expect(roth_401k).to receive(:buy).with(scenario.projections_start, contribution)
          expect(income_account).to receive(:record_pretax_401k_contribution).with(scenario.projections_start, contribution)
          expect(income_account).to receive(:record_aftertax_401k_contribution).with(scenario.projections_start, contribution)

          Projector.new(scenario).project(scenario.projections_start)
        end
 
        it 'should factor in YTD contributions' do
          [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
            allow(account).to receive(:project)
            allow(account).to receive(:summary)
            allow(account).to receive(:transact)
          end

          contribution_limit = (savings_balance / 10).round(2)
          allow(tax_info).to receive(:annual_401k_contribution_limit_for_year).with(scenario.starting_month.year).and_return(contribution_limit)
          allow(income_account).to receive(:ytd_401k_contributions).with(scenario.projections_start).and_return((contribution_limit / 2).round(2))
          allow(expense_account).to receive(:project)
          allow(expense_account).to receive(:amount).and_return(0)
          contribution = ((contribution_limit / (12 - scenario.projections_start.month + 1)) / 4).round(2)
          expect(traditional_401k).to receive(:buy).with(scenario.projections_start, contribution)
          expect(roth_401k).to receive(:buy).with(scenario.projections_start, contribution)
          expect(income_account).to receive(:record_pretax_401k_contribution).with(scenario.projections_start, contribution)
          expect(income_account).to receive(:record_aftertax_401k_contribution).with(scenario.projections_start, contribution)

          expect(mutual_fund).to receive(:buy).with(scenario.projections_start, savings_balance - Projector::MINIMUM_SAVINGS - contribution * 2)
          expect(savings_account).to receive(:debit).with(scenario.projections_start, savings_balance - Projector::MINIMUM_SAVINGS - contribution * 2)
          Projector.new(scenario).project(scenario.projections_start)
        end
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
        expect(mutual_fund).to receive(:buy).with(scenario.projections_start, savings_balance - (savings_balance * 6 / 10).round(0))
        expect(savings_account).to receive(:debit).with(scenario.projections_start, savings_balance - (savings_balance * 6 / 10).round(0))
        Projector.new(scenario).project(scenario.projections_start)
      end
 
      it 'should project & transact all accounts, buying stock while leaving minimum savings' do
        [savings_account, income_account, expense_account, mutual_fund, traditional_401k, roth_401k].each do |account|
          expect(account).to receive(:project).with(scenario.starting_month)
          expect(account).to receive(:summary).with(scenario.starting_month)
          expect(account).to receive(:transact)
        end

        current = scenario.projections_start
        6.times do
          allow(expense_account).to receive(:project).with(current)
          allow(expense_account).to receive(:amount).with(current).and_return(0)
          current = current.next
        end
        min_savings = Projector::MINIMUM_SAVINGS
        expect(mutual_fund).to receive(:buy).with(scenario.projections_start, savings_balance - min_savings)
        expect(savings_account).to receive(:debit).with(scenario.projections_start, savings_balance - min_savings)
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
