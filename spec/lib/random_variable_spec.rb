require 'rails_helper'

describe RandomVariable do

  describe '#stdev=' do
    let(:var) { build(:random_variable) }
    it 'should set the stdev' do
      var.stdev = 65.0
      expect(var.stdev).to eq(65.0)
    end
    it 'should default set the stdev to zero' do
      var.stdev = nil
      expect(var.stdev).to eq(0)
    end
  end

  describe '#sample' do

    context 'when stdev is zero or not provided' do
      let(:var) { build(:random_variable, :no_stdev) }
      it 'should return the mean' do
        expect(var.sample).to eq(var.mean)
      end
    end

    context 'when stdev is provided' do
      let(:var) { build(:random_variable) }
      let(:rand_values) { [0.6406128959171591] }
      it 'should sample from a normal distribution' do
        dist = instance_double(Rubystats::NormalDistribution)
        allow(dist).to receive(:rng).and_return(*rand_values)
        allow(Rubystats::NormalDistribution).to receive(:new).and_return(dist)
        expect(var.sample).to eq(rand_values[0])
      end
    end

  end

end
