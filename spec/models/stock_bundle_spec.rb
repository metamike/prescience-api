require 'rails_helper'

describe StockBundle, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:month_bought) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount) }

    let(:bundle) { build(:stock_bundle) }
    let(:activity1) { build(:stock_activity, month: bundle.month_bought) }
    let(:activity2) { build(:stock_activity, month: activity1.month.next) }

    it 'should fail if activities are out of order' do
      bundle.stock_activities << activity2
      expect(bundle.valid?).to be(false)
    end

    it 'should validate that activities are in order' do
      bundle.stock_activities << activity1
      bundle.stock_activities << activity2
      expect(bundle.valid?).to be(true)
    end
  end

end

