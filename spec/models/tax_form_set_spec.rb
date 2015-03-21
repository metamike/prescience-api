require 'rails_helper'

describe TaxFormSet do

  let(:form_set) { TaxFormSet.new }

  context 'with no forms' do
    it 'should fail when referencing anything' do
      expect { form_set.f1040 }.to raise_error(NoMethodError)
    end
  end

  context 'with a single form' do
    it 'should allow references to this form' do
      form_set.form(1040)
      expect(form_set.f1040.class).to be(TaxForm)
    end
  end

end
