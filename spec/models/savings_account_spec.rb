require 'rails_helper'

describe SavingsAccount, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:interest_rate) }
    it { should validate_presence_of(:starting_month) }
    # TODO These don't work for some reason
    # it { should validate_presence_of(:starting_balance) }
    # it { should validate_numericality_of(:starting_balance) }
  end

  let(:account) { build(:savings_account) }

  it 'should use overrides if they are set' do
    override = MonthlyOverride.create!(month: Month.new(2014, 11), amount: 45.14)
    account.monthly_overrides << override
    val = account.calc(Month.new(2014, 11))
    expect(val).to eq(45.14)
  end

end
