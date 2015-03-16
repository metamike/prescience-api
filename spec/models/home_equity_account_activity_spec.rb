require 'rails_helper'

describe HomeEquityAccountActivity, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:month) }
    [:principal, :interest].each do |field|
      it { should validate_presence_of(field) }
      it { should validate_numericality_of(field) }
    end
  end

end

