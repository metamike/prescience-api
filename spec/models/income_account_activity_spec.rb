require 'rails_helper'

describe IncomeAccountActivity, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:month) }
    it { should validate_presence_of(:gross) }
    it { should validate_numericality_of(:gross) }
  end

end

