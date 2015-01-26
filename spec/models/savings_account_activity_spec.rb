require 'rails_helper'

describe SavingsAccountActivity, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:month) }
    it { should validate_presence_of(:interest) }
    it { should validate_numericality_of(:interest) }
    it { should validate_presence_of(:ending_balance) }
    it { should validate_numericality_of(:ending_balance) }
  end

end

