require 'rails_helper'

describe MutualFund, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:monthly_interest_rate) }
  end

end
