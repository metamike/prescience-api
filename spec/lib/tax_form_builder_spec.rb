require 'rails_helper'

describe TaxFormBuilder do

  after :each do
    TaxFormBuilder.reset
  end

  describe '.constructify' do
    context 'with no block' do
      it 'should fail' do
        expect { TaxFormBuilder.constructify }.to raise_error
      end
    end
    context 'with an empty block' do
      it 'should not fail' do
        expect { TaxFormBuilder.constructify {} }.to_not raise_error
      end
    end
    context 'with a single form' do
      it 'should generate a form object' do
        TaxFormBuilder.constructify { form '1040' }
        expect(TaxFormBuilder.form_set.forms['1040'].class).to eq(TaxForm)
      end
    end

    context 'with a cell in a form' do
      it 'should generate the form properly' do
        TaxFormBuilder.constructify do
          form '1040' do
            cell '1', 50
          end
        end
        form = TaxFormBuilder.form_set.forms['1040']
        expect(form.c1).to eq(50)
      end
    end

  end

  describe '.reset' do
    it 'should reset the form set' do
      TaxFormBuilder.constructify { form 'ca540' }
      TaxFormBuilder.reset
      expect(TaxFormBuilder.form_set.forms).to be_empty
    end
  end

end
