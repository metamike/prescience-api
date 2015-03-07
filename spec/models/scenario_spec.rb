require 'rails_helper'

describe Scenario, :type => :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:projections_start) }
  end

  describe '#savings_account_by_owner' do
    let(:scenario) { build(:scenario) }
    let(:owner) { build(:owner) }

    context 'with no accounts' do
      it 'should return nil' do
        expect(scenario.savings_account_by_owner(owner)).to be_nil
      end
    end

    context 'with accounts' do
      let(:savings1) { build(:savings_account) }
      let(:savings2) { build(:savings_account, owner: owner) }

      before :each do
        scenario.savings_accounts += [savings1, savings2]
      end

      it 'should return nil when no owner is passed' do
        expect(scenario.savings_account_by_owner(nil)).to be_nil
      end

      it 'should return the correct account by owner' do
        expect(scenario.savings_account_by_owner(owner)).to eq(savings2)
      end
    end

  end

end
