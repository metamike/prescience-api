require 'rails_helper'

describe Scenario, :type => :model do

  context 'validations' do
    it { should validate_uniqueness_of(:name) }
  end

end
