require 'rails_helper'
require './lib/month'

describe Month do

  it 'should only parse valid month formats' do
    month = Month.parse('2014-09')
    expect(month.year).to eq(2014)
    expect(month.month).to eq(9)
  end

  it 'should fail parsing invalid months' do
    expect { Month.parse('2014-10-02') }.to raise_error
  end

  it 'should return the next month' do
    month = Month.new(2013, 11)
    expect(month.next).to eq(Month.new(2013, 12))
    expect(month.next.next).to eq(Month.new(2014, 1))
  end

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
