require 'rails_helper'

describe StockActivity, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:month) }
    it { should validate_numericality_of(:sold) }
    it { should validate_presence_of(:performance) }
    it { should validate_numericality_of(:performance) }
    it { should validate_numericality_of(:dividends) }
  end

end

