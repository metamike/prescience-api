require 'rails_helper'

describe ExpenseAccount, :type => :model do

  let(:account) { build(:expense_account) }
  let(:activity) { build(:expense_account_activity, month: account.starting_month, expense_account: account) }

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:starting_amount) }
    it { should validate_numericality_of(:starting_amount) }

    let(:activity_good) { build(:expense_account_activity, month: activity.month.next, expense_account: account) }
    let(:activity_bad) { build(:expense_account_activity, month: activity.month.next.next, expense_account: account) }

    it 'should fail if activities are out of order' do
      account.expense_account_activities << activity
      expect(account.valid?).to be(true)
      account.expense_account_activities << activity_bad
      expect(account.valid?).to be(false)
    end

    it 'should validate that activities are in order' do
      account.expense_account_activities << activity
      account.expense_account_activities << activity_good
      expect(account.valid?).to be(true)
    end
  end

end

