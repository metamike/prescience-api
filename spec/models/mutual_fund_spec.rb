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

      context 'with taxable activity' do
        let(:bundle) { build(:stock_bundle, :with_activity, month_bought: account.starting_month) }
        it 'should use historicals' do
          account.stock_bundles << bundle
          account.project(account.starting_month)
          activity = bundle.stock_activities.sort_by(&:month).first
          expect(account.taxable_performance(account.starting_month)).to eq(activity.performance)
          expect(account.qualified_performance(account.starting_month)).to eq(0)
          expect(account.taxable_dividends(account.starting_month)).to eq(activity.dividends)
          expect(account.qualified_dividends(account.starting_month)).to eq(0)
          expect(account.ending_balance(account.starting_month)).to eq(bundle.amount + activity.performance + activity.dividends)
        end
      end

      context 'with qualified activity' do
        let(:bundle) { build(:stock_bundle, :with_qualified_activity, month_bought: account.starting_month) }
        it 'should use historicals' do
          account.stock_bundles << bundle
          last_activity = bundle.stock_activities.sort_by(&:month).last
          account.starting_month.upto(last_activity.month) do |month|
            account.project(month)
          end
          expect(account.taxable_performance(last_activity.month)).to eq(0)
          expect(account.qualified_performance(last_activity.month)).to eq(last_activity.performance)
          expect(account.taxable_dividends(last_activity.month)).to eq(0)
          expect(account.qualified_dividends(last_activity.month)).to eq(last_activity.dividends)
        end
      end

    end

    context 'with multiple bundles and activity' do
      let(:account) { build(:mutual_fund) }
      let(:bundle1) { build(:stock_bundle, :with_activities, month_bought: account.starting_month) }
      let(:bundle2) { build(:stock_bundle, :with_activity, month_bought: account.starting_month.next) }
      it 'should sum results from bundles' do
        account.stock_bundles += [bundle1, bundle2]
        # First month
        account.project(account.starting_month)
        performance1 = bundle1.stock_activities.sort_by(&:month).first.performance
        dividends1 = bundle1.stock_activities.sort_by(&:month).first.dividends
        expect(account.taxable_performance(account.starting_month)).to eq(performance1)
        expect(account.qualified_performance(account.starting_month)).to eq(0)
        expect(account.taxable_dividends(account.starting_month)).to eq(dividends1)
        expect(account.qualified_dividends(account.starting_month)).to eq(0)
        expect(account.ending_balance(account.starting_month)).to eq(bundle1.amount + performance1 + dividends1)
        # Second month
        month = account.starting_month.next
        account.project(month)
        performance2 = [bundle1, bundle2].reduce(0) { |a, e| a += e.stock_activities.find { |s| s.month == month }.performance }
        dividends2 = [bundle1, bundle2].reduce(0) { |a, e| a += e.stock_activities.find { |s| s.month == month }.dividends }
        bundle1div2 = bundle1.stock_activities.sort_by(&:month).last.dividends
        expect(account.taxable_performance(month)).to eq(performance2)
        expect(account.qualified_performance(month)).to eq(0)
        expect(account.taxable_dividends(month)).to eq(dividends2)
        expect(account.qualified_dividends(month)).to eq(0)
        expect(account.ending_balance(month)).to eq(bundle1.amount + bundle2.amount + performance1 + dividends1 + performance2 + dividends2 - bundle1div2)
      end
    end

    context 'with sold stock' do
      let(:account) { build(:mutual_fund) }
      let(:bundle) { build(:stock_bundle, :with_sale, month_bought: account.starting_month) }
      it 'should account for the sale of stock' do
        account.stock_bundles << bundle
        account.project(account.starting_month)
        performance = bundle.stock_activities.sort_by(&:month).first.performance
        dividends = bundle.stock_activities.sort_by(&:month).first.dividends
        expect(account.taxable_performance(account.starting_month)).to eq(performance)
        expect(account.qualified_performance(account.starting_month)).to eq(0)
        expect(account.taxable_dividends(account.starting_month)).to eq(dividends)
        expect(account.qualified_dividends(account.starting_month)).to eq(0)
        expect(account.ending_balance(account.starting_month)).to eq(bundle.amount + performance + dividends - bundle.stock_activities.first.sold)
      end
    end

  end

end
