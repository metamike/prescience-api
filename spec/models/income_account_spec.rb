require 'rails_helper'

describe IncomeAccount, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    # TODO These don't work for some reason
    # it { should validate_presence_of(:starting_balance) }
    # it { should validate_numericality_of(:starting_balance) }
  end

  let(:account) { build(:income_account) }

  it 'should use overrides if they are set' do
    override = MonthlyOverride.create!(month: Month.new(2014, 11), amount: 45.14)
    account.monthly_overrides << override
    val = account.calc(Month.new(2014, 11))
    expect(val).to eq(45.14)
  end

  it 'should error when requesting a date before the present' do
    expect { account.calc(account.starting_month.prior) }.to raise_error
  end

  it 'should use the interest rate to calculate with precision' do
    val = account.calc(account.starting_month)
    expect(val).to eq((1 + account.interest_rate) * account.starting_balance)
    val2 = account.calc(account.starting_month.next)
    expect(val2).to eq((1 + account.interest_rate)**2 * account.starting_balance)
    puts "#{account.interest_rate} - #{account.starting_balance}"
    val3 = account.calc(account.starting_month.next.next)
    expect(val3).to eq((1 + account.interest_rate)**3 * account.starting_balance)
    val4 = account.calc(account.starting_month.next.next.next)
    expect(val4).to eq((1 + account.interest_rate)**4 * account.starting_balance)
  end

end

