require 'rails_helper'

describe TaxForm do

  let(:form_set) { double(TaxFormSet) }

  context 'with no cells' do
    it 'should fail when referencing a cell' do
      allow(form_set).to receive(:c1).and_raise(NoMethodError)
      form = TaxForm.new(form_set)
      expect { form.c1 }.to raise_error(NoMethodError)
    end
  end

  context 'with a value cell' do
    let(:form) { TaxForm.new(form_set).cell('1', 56) }
    let(:form_with_name) { TaxForm.new(form_set).cell('1', :name, 'string') }
    it 'should return the cell''s value' do
      expect(form.c1).to eq(56)
    end
    it 'should return the cell''s value by name' do
      expect(form_with_name.name).to eq('string')
    end
  end

  context 'with lambdas' do
    let(:form) do
      TaxForm.new(form_set)
        .cell('1', proc { 9 })
        .cell('2', :fun, 10)
        .cell('3', proc { c1 + fun })
    end
    it 'should evaluate the lambda' do
      expect(form.c1).to eq(9)
    end
    it 'should navigate references' do
      expect(form.c3).to eq(19)
    end
  end

  context 'with references to other forms' do
    let(:form_double) { double(TaxForm) }
    let(:form) do
      TaxForm.new(form_set)
        .cell('1', proc { f1040.c4 })
        .cell('2', :friday, 50)
        .cell('3', proc { friday })
    end
    it 'should find form references' do
      allow(form_set).to receive(:send).with(:f1040).and_return(form_double)
      allow(form_double).to receive(:c4)
      expect(form_set).to receive(:send).with(:f1040)
      expect(form_double).to receive(:c4)
      form.c1
    end
    it 'should have the current form take precedence' do
      allow(form_set).to receive(:send).with(:friday).and_return('BAD')
      expect(form.c3).to eq(50)
    end
  end

end
