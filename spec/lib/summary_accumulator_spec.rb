require 'rails_helper'

describe SummaryAccumulator do

  describe '#merge' do

    let(:accumulator) { SummaryAccumulator.new }

    it 'should not fail w/ nil' do
      accumulator.merge(nil)
      expect(accumulator.summary).to eq({})
    end

    it 'should handle empty hashes' do
      accumulator.merge({})
      expect(accumulator.summary).to eq({})
    end

    it 'should handle single-level hashes' do
      hash1 = {'a' => 123, 'b' => 456}
      hash2 = {'b' => 333, 'c' => 678}
      accumulator.merge(hash1)
      expect(accumulator.summary).to eq(hash1)
      accumulator.merge(hash2)
      expect(accumulator.summary).to eq({
        'a' => 123, 'b' => 789, 'c' => 678
      })
    end

    it 'should handle nested hashes' do
      hash1 = {'a' => 123, 'b' => {'x' => 10, 'y' => {'e' => 11, 'f' => 12}}}
      hash2 = {'a' => 0, 'b' => {'x' => 5, 'y' => {'f' => 55, 'g' => 7}, 'z' => 6}}
      merged = {
        'a' => 123,
        'b' => {
          'x' => 15,
          'y' => {
            'e' => 11,
            'f' => 67,
            'g' => 7
          },
          'z' => 6
        }
      }
      accumulator.merge(hash1)
      accumulator.merge(hash2)
      expect(accumulator.summary).to eq(merged)
    end

    it 'should handle BigDecimals' do
      hash1 = {'a' => BigDecimal.new('67.05')}
      hash2 = {'a' => 20}
      hash3 = {'a' => BigDecimal.new('-455.88')}
      [hash1, hash2, hash3].each { |h| accumulator.merge(h) }
      expect(accumulator.summary).to eq({'a' => BigDecimal.new('-368.83')})
    end

  end

end
