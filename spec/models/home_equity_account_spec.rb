require 'rails_helper'

def monthly_payment(account)
  period_rate = account.interest_rate / 12.0
  (account.loan_amount * (period_rate * (1 + period_rate) ** account.loan_term_months) /
    ((1 + period_rate) ** account.loan_term_months - 1)).round(2)
end

describe HomeEquityAccount, type: :model do

  context 'validations' do

    let(:account) { build(:home_equity_account, :with_activity) }
    let(:bad_activity) { build(:home_equity_account_activity, month: account.month_bought.next.next) }
    let(:good_activity) { build(:home_equity_account_activity, month: account.month_bought.next) }

    [:month_bought, :loan_amount, :loan_term_months, :interest_rate].each do |field|
      it { should validate_presence_of(field) }
    end
    [:loan_amount, :loan_term_months, :interest_rate].each do |field|
      it { should validate_numericality_of(field) }
    end

    it 'should fail if activities are out of order' do
      expect(account.valid?).to be(true)
      account.home_equity_account_activities << bad_activity
      expect(account.valid?).to be(false)
    end

    it 'should validate that activities are in order' do
      account.home_equity_account_activities << good_activity
      expect(account.valid?).to be(true)
    end
  end

  describe '#project' do

    context 'with historicals' do
      let(:account) { build(:home_equity_account) }
      let(:activity) { build(:home_equity_account_activity, month: account.month_bought) }
      let(:activity2) { build(:home_equity_account_activity, month: account.month_bought.next) }

      before :each do
        account.home_equity_account_activities += [activity, activity2]
      end

      it 'should use those historicals' do
        account.project(account.month_bought)
        expect(account.principal(account.month_bought)).to eq(activity.principal)
        expect(account.interest(account.month_bought)).to eq(activity.interest)
        expect(account.ending_balance(account.month_bought)).to eq(account.loan_amount - activity.principal)
      end

      it 'should reference priors to determine ending balance' do
        account.project(account.month_bought)
        account.project(activity2.month)
        expect(account.ending_balance(activity2.month)).to eq(account.loan_amount - activity.principal - activity2.principal)
      end
    end

    context 'without historicals' do
      let(:account) { build(:home_equity_account) }

      it 'should calculate correctly at beginning of term' do
        payment = monthly_payment(account)
        interest = (account.loan_amount * account.interest_rate / 12.0).round(2)
        account.project(account.month_bought)
        expect(account.principal(account.month_bought)).to eq(payment - interest)
        expect(account.interest(account.month_bought)).to eq(interest)
        expect(account.ending_balance(account.month_bought)).to eq(account.loan_amount - payment + interest)
      end

      it 'should calculate final payment at end of term' do
        current = account.month_bought
        (account.loan_term_months + 1).times do
          account.project(current)
          current = current.next
        end
        current = current.prior
        current = current.prior if account.principal(current) == 0
        expect(account.principal(current)).to eq(account.ending_balance(current.prior))
        expect(account.interest(current)).to eq((account.ending_balance(current.prior) * account.interest_rate / 12.0).round(2))
        expect(account.ending_balance(current)).to eq(0)
        # Next month should be zeroes
        account.project(current.next)
        expect(account.principal(current.next)).to eq(0)
        expect(account.interest(current.next)).to eq(0)
        expect(account.ending_balance(current.next)).to eq(0)
      end

      it 'should be idempotent' do
        account.project(account.month_bought)
        principal = account.principal(account.month_bought)
        interest = account.interest(account.month_bought)
        ending_balance = account.ending_balance(account.month_bought)
        account.project(account.month_bought)
        expect(account.principal(account.month_bought)).to eq(principal)
        expect(account.interest(account.month_bought)).to eq(interest)
        expect(account.ending_balance(account.month_bought)).to eq(ending_balance)
      end
    end

  end

  describe '#transact' do

    let(:account) { build(:home_equity_account) }
    
    it 'should fail when not projected' do
      expect { account.transact(account.month_bought) }.to raise_error
    end

    it 'should call expense' do
      allow(account).to receive(:expense)
      account.project(account.month_bought)
      expect(account).to receive(:expense).with(account.month_bought, account.principal(account.month_bought) + account.interest(account.month_bought))
      account.transact(account.month_bought)
    end

  end

  describe '#summary' do
 
    let(:account) { build(:home_equity_account) }

    it 'should summarize stats when not projected' do
      expected = {'home equity' => {
        'starting balance' => account.loan_amount,
        'principal' => 0, 'interest' => 0, 'ending balance' => 0
      }}
      expect(account.summary(account.month_bought)).to eq(expected)
    end

    it 'should summarize projected values' do
      account.project(account.month_bought)
      expected = {'home equity' => {
        'starting balance' => account.starting_balance(account.month_bought),
        'principal' => account.principal(account.month_bought),
        'interest' => account.interest(account.month_bought),
        'ending balance' => account.ending_balance(account.month_bought)
      }}
      expect(account.summary(account.month_bought)).to eq(expected)
    end

  end

end

