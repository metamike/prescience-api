require 'rails_helper'

describe Month do

  describe '.parse' do
    it 'should only parse valid month formats' do
      month = Month.parse('2014-09')
      expect(month.year).to eq(2014)
      expect(month.month).to eq(9)
    end

    it 'should fail parsing invalid months' do
      expect { Month.parse('2014-10-02') }.to raise_error
    end
  end

  describe '#next' do
    let(:month) { build(:month, year: 2013, month: 11) }
    let(:month2) { build(:month, year: 2013, month: 12) }
    let(:month3) { build(:month, year: 2014, month: 1) }
    it 'should return the next month' do
      expect(month.next).to eq(month2)
      expect(month.next.next).to eq(month3)
    end
  end

  describe '#upto' do
    it 'should iterate over months' do
      month = Month.new(2013, 9)
      calls = 0
      month.upto(Month.new(2013, 8)) { calls += 1 }
      expect(calls).to eq(0)
      month.upto(Month.new(2013, 9)) { calls += 1 }
      expect(calls).to eq(1)

      array = []
      month.upto(Month.new(2014, 2)) { |m| array << m }
      expect(array).to eq([Month.new(2013, 9), Month.new(2013, 10), Month.new(2013, 11),
                           Month.new(2013, 12), Month.new(2014, 1), Month.new(2014, 2)])
    end
  end

  describe '#-' do
    it 'should subtract months' do
      month = Month.new(2013, 9)
      expect(month - Month.new(2013, 9)).to eq(0)
      expect(month - Month.new(2012, 10)).to eq (11)
      expect(month - Month.new(2012, 9)).to eq(12)
      expect(month - Month.new(2014, 1)).to eq(-4)
    end
  end

  describe '#year_diff' do
    it 'should subtract years' do
      month = Month.new(2013, 9)
      expect(month.year_diff(Month.new(2013, 10))).to eq(0)
      expect(month.year_diff(Month.new(2015, 1))).to eq(-2)
      expect(month.year_diff(Month.new(2010, 50))).to eq(3)
    end
  end

  describe '.dump' do
    context 'when nil' do
      it 'should not break' do
        expect(Month.dump(nil)).to be_nil
      end
    end
    context 'with a valid month' do
      let(:month) { build(:month) }
      it 'should dump a JSON string' do
        json = JSON.load(Month.dump(month))
        expect(json['year']).to eq(month.year)
        expect(json['month']).to eq(month.month)
      end
    end
  end

  describe '.load' do
    context 'when nil' do
      it 'should not break' do
        expect(Month.load(nil)).to be_nil
      end
    end
    context 'with a JSON string' do
      let(:hash) { {'year' => 2012, 'month' => 11} }
      it 'should generate a valid month' do
        month = Month.load(hash.to_json)
        expect(month.year).to eq(hash['year'])
        expect(month.month).to eq(hash['month'])
      end
    end
  end

end
