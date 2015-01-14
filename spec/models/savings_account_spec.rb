require 'rails_helper'

describe SavingsAccount, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:interest_rate) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:starting_balance) }
    it { should validate_numericality_of(:starting_balance) }
  end

end
