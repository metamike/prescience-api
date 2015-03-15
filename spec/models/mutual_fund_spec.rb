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

    context 'projecting with single bundle' do

      context 'with simpleness' do
        let(:account) { build(:mutual_fund) }
        let(:bundle) { build(:stock_bundle, :with_activity, month_bought: account.starting_month) }
        it 'should project one month forward' do
          account.stock_bundles << bundle
          month = account.starting_month.next
          account.project(month)
          bal = bundle.amount + bundle.stock_activities.first.performance + bundle.stock_activities.first.dividends - bundle.stock_activities.first.sold
          expect(account.ending_balance(month)).to eq((bal * (1 + account.monthly_interest_rate.sample)).round(2))
        end
      end

      context 'without dividends' do
        let(:account) { build(:mutual_fund) }
        let(:bundle) { build(:stock_bundle, :with_activity, month_bought: account.starting_month) }
        it 'should project two months forward w/o dividends' do
          account.stock_bundles << bundle
          month = account.starting_month.next.next
          account.project(account.starting_month.next)
          account.project(month)
          # a1
          # a2
          # a3
          bal_a1 = bundle.amount + bundle.stock_activities.first.performance + bundle.stock_activities.first.dividends - bundle.stock_activities.first.sold
          bal_a2 = (bal_a1 * (1 + account.monthly_interest_rate.sample)).round(2)
          bal_a3 = (bal_a2 * (1 + account.monthly_interest_rate.sample)).round(2)
          expect(account.ending_balance(month)).to eq(bal_a3)
        end
      end

      context 'with dividends' do
        let(:account) { build(:mutual_fund, starting_month: build(:month, year: 2014, month: 11)) }
        let(:bundle) { build(:stock_bundle, :with_activity, month_bought: account.starting_month) }
        it 'should project two months forward w/ dividends' do
          account.stock_bundles << bundle
          month = account.starting_month.next.next
          account.project(account.starting_month.next)
          account.project(month)
          # a1
          # a2 b2
          # a3 b3
          bal_a1 = bundle.amount + bundle.stock_activities.first.performance + bundle.stock_activities.first.dividends - bundle.stock_activities.first.sold
          bal_a2 = (bal_a1 * (1 + account.monthly_interest_rate.sample)).round(2)
          bal_b2 = (bal_a1 * account.quarterly_dividend_rate.sample).round(2)
          bal_a3 = (bal_a2 * (1 + account.monthly_interest_rate.sample)).round(2)
          bal_b3 = (bal_b2 * (1 + account.monthly_interest_rate.sample)).round(2)
          expect(account.ending_balance(month)).to eq(bal_a3 + bal_b3)
        end
      end
    end

  end

  describe '#prepare_to_reproject' do
    let(:account) { build(:mutual_fund, :with_uncertain_interest) }
    let(:bundle) { build(:stock_bundle, :with_activity, month_bought: account.starting_month) }
    it 'should return the same data when projecting again' do
      account.stock_bundles << bundle
      account.project(account.starting_month.next)
      balance = account.ending_balance(account.starting_month.next)
      account.prepare_to_reproject
      account.project(account.starting_month.next)
      expect(account.ending_balance(account.starting_month.next)).to eq(balance)
    end
  end

  describe '#transact' do
    let(:account) { build(:mutual_fund) }
    it 'should not fail' do
      expect { account.transact(account.starting_month) }.to_not raise_error
    end
  end

  describe '#summary' do
    let(:account) { build(:mutual_fund) }
    let(:bundle) { build(:stock_bundle, :with_activity, month_bought: account.starting_month) }

    before :each do
      account.stock_bundles << bundle
    end

    it 'should return summaries' do
      expected = {'mutual funds' => {
        'starting balance' => account.starting_balance(account.starting_month),
        'bought' => account.bought(account.starting_month),
        'sold' => account.sold(account.starting_month),
        'performance' => account.taxable_performance(account.starting_month) + account.qualified_performance(account.starting_month),
        'dividends' => account.taxable_dividends(account.starting_month) + account.qualified_dividends(account.starting_month),
        'ending balance' => account.ending_balance(account.starting_month)
      }}
      account.project(account.starting_month)
      expect(account.summary(account.starting_month)).to eq(expected)
    end
  end

end
