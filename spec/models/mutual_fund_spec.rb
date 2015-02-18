require 'rails_helper'

describe MutualFund, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:monthly_interest_rate) }
  end

  describe '#project' do

    context 'with no bundles' do
      let(:account) { build(:mutual_fund) }
      it 'should return 0' do
        account.project(account.starting_month)
        expect(account.taxable_performance(account.starting_month)).to eq(0)
        expect(account.qualified_performance(account.starting_month)).to eq(0)
        expect(account.taxable_dividends(account.starting_month)).to eq(0)
        expect(account.qualified_dividends(account.starting_month)).to eq(0)
        expect(account.ending_balance(account.starting_month)).to eq(0)
      end
    end

    context 'with one bundle' do
      let(:account) { build(:mutual_fund) }
      let(:bundle) { build(:stock_bundle, month_bought: account.starting_month) }

      context 'with activity' do
        let(:activity) { build(:stock_activity, month: bundle.month_bought) }
        it 'should use historicals' do
          bundle.stock_activities << activity
          account.stock_bundles << bundle
          account.project(account.starting_month)
          expect(account.taxable_performance(account.starting_month)).to eq(activity.performance)
          expect(account.qualified_performance(account.starting_month)).to eq(0)
          expect(account.taxable_dividends(account.starting_month)).to eq(0)
          expect(account.qualified_dividends(account.starting_month)).to eq(0)
          expect(account.ending_balance(account.starting_month)).to eq(bundle.amount + activity.performance)
        end
      end
    end

  end

end
