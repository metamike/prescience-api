require 'rails_helper'

describe ExpenseAccountActivity, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:month) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount) }
  end

end

