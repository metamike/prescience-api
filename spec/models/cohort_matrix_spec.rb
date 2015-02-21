require 'rails_helper'

describe CohortMatrix do

  let(:matrix) { build(:cohort_matrix) }
  let(:month) { build(:month) }
  let(:buy) { 50000 }

  context 'with no data' do
    it 'should not raise errors' do
      expect(matrix.cohort_ending_balance(month, month)).to eq(0)
      expect(matrix.ending_balance(month)).to eq(0)
      expect(matrix.bought(month)).to eq(0)
      expect(matrix.sold(month)).to eq(0)
      expect(matrix.taxable_performance(month)).to eq(0)
      expect(matrix.qualified_performance(month)).to eq(0)
      expect(matrix.taxable_dividends(month)).to eq(0)
      expect(matrix.qualified_dividends(month)).to eq(0)
    end
  end

  context 'with single month' do
    it 'should return purchase amount' do
      matrix.record_buy(month, buy)
      expect(matrix.cohort_ending_balance(month, month)).to eq(buy)
      expect(matrix.ending_balance(month)).to eq(buy)
      expect(matrix.bought(month)).to eq(buy)
    end

    it 'should respect stock events' do
      sell = 5000
      performance = 100
      dividends = 20
      matrix.record_buy(month, buy)
      matrix.record_performance(month, month, performance)
      matrix.record_dividends(month, month, dividends, false)
      matrix.record_sell(month, month, sell)
      expect(matrix.cohort_ending_balance(month, month)).to eq(buy + performance + dividends - sell)
      expect(matrix.taxable_performance(month)).to eq(performance)
      expect(matrix.taxable_dividends(month)).to eq(dividends)
      expect(matrix.sold(month)).to eq(sell)
    end
  end

  context 'with a single cohort and two months' do
    it 'should respect stock events' do
      sell = 5000
      performance = 100
      matrix.record_buy(month, buy)
      matrix.record_performance(month, month, performance)
      matrix.record_sell(month, month, sell)
      matrix.record_performance(month, month.next, performance)
      matrix.record_sell(month, month.next, sell)
      expect(matrix.cohort_ending_balance(month, month.next)).to eq(buy + performance * 2 - sell * 2)
      expect(matrix.taxable_performance(month.next)).to eq(performance)
    end

    it 'should only count dividends in first month' do
      dividends = 50
      matrix.record_buy(month, buy)
      matrix.record_dividends(month, month, dividends, false)
      matrix.record_dividends(month, month.next, dividends, false)
      expect(matrix.cohort_ending_balance(month, month.next)).to eq(buy + dividends)
      expect(matrix.taxable_dividends(month.next)).to eq(dividends)
    end
  end

  context 'with multiple cohorts' do
    it 'should create new cohorts when there are dividends present' do
      performance = 500
      dividends = 100
      matrix.record_buy(month, buy)
      matrix.record_performance(month, month, performance)
      matrix.record_dividends(month, month.next, dividends)
      expect(matrix.cohort_ending_balance(month, month.next)).to eq(buy + performance)
      expect(matrix.cohort_ending_balance(month.next, month.next)).to eq(dividends)
      expect(matrix.ending_balance(month.next)).to eq(buy + performance + dividends)
      expect(matrix.taxable_dividends(month.next)).to eq(dividends)
      expect(matrix.bought(month.next)).to eq(dividends)
    end

    it 'should aggregate purchases in the same month' do
      matrix.record_buy(month, buy)
      matrix.record_buy(month, buy)
      expect(matrix.cohort_ending_balance(month, month)).to eq(buy * 2)
      expect(matrix.bought(month)).to eq(buy * 2)
    end

    it 'should aggregate stock events' do
      performance = 300
      dividends = 105
      sell = 10000
      # First Run
      matrix.record_buy(month, buy)
      matrix.record_performance(month, month, performance)
      matrix.record_dividends(month, month, dividends, false)
      matrix.record_performance(month, month.next, performance)
      matrix.record_dividends(month, month.next, dividends, false)
      matrix.record_sell(month, month.next, sell)
      matrix.record_buy(month.next, dividends)
      # Second Run
      matrix.record_buy(month, buy)
      matrix.record_performance(month, month, performance)
      matrix.record_dividends(month, month, dividends, false)
      matrix.record_performance(month, month.next, performance)
      matrix.record_dividends(month, month.next, dividends, false)
      matrix.record_sell(month, month.next, sell)
      matrix.record_buy(month.next, dividends)
      expect(matrix.cohort_ending_balance(month, month)).to eq(buy * 2 + performance * 2 + dividends * 2)
      expect(matrix.cohort_ending_balance(month, month.next)).to eq(buy * 2 + performance * 4 + dividends * 2 - sell * 2)
      expect(matrix.cohort_ending_balance(month.next, month.next)).to eq(dividends * 2)
      expect(matrix.ending_balance(month)).to eq(buy * 2 + performance * 2 + dividends * 2)
      expect(matrix.ending_balance(month.next)).to eq(buy * 2 + performance * 4 + dividends * 4 - sell * 2)
      expect(matrix.taxable_performance(month.next)).to eq(performance * 2)
      expect(matrix.taxable_dividends(month.next)).to eq(dividends * 2)
      expect(matrix.bought(month.next)).to eq(dividends * 2)
      expect(matrix.sold(month.next)).to eq(sell * 2)
    end
  end

end

