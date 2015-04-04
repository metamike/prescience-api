require 'rails_helper'

describe TaxFormSet do

  let(:form_set) { TaxFormSet.new }
  let(:account) { mock_model(IncomeTaxAccount) }
  let(:historic_tax_year) { 1000 }
  let(:new_tax_year) { 1001 }
  let(:activity) { mock_model(IncomeTaxActivity) }
  let(:scenario) { mock_model(Scenario) }
  let(:income_account1) { mock_model(IncomeAccount) }
  let(:income_account2) { mock_model(IncomeAccount) }
  let(:owner) { mock_model(Owner) }
  let(:owner_id) { 5 }

  before :each do
    allow(account).to receive(:income_tax_activities).and_return([activity])
    allow(account).to receive(:scenario).and_return(scenario)
    allow(account).to receive(:filing_status).and_return('single')
    allow(account).to receive(:owner_id).and_return(owner_id)
    allow(activity).to receive(:year).and_return(historic_tax_year)
    allow(activity).to receive(:filing_status).and_return('married')
    allow(activity).to receive(:wages).and_return(BigDecimal.new('10000'))
    allow(scenario).to receive(:income_accounts).and_return([income_account1, income_account2])
    allow(income_account1).to receive(:gross).and_return(BigDecimal.new('2000'))
    allow(income_account1).to receive(:owner_id).and_return(owner_id)
    allow(income_account2).to receive(:gross).and_return(BigDecimal.new('3000'))
  end

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

  describe '#filing_status' do
    it 'should return historical filing status' do
      form_set.run(account, historic_tax_year)
      expect(form_set.filing_status).to eq(activity.filing_status)
    end
    it 'should return non-historical filing status' do
      form_set.run(account, new_tax_year)
      expect(form_set.filing_status).to eq(account.filing_status)
    end
  end

  describe '#wages' do
    it 'should return historical wages' do
      form_set.run(account, historic_tax_year)
      expect(form_set.wages).to eq(activity.wages)
    end
    context 'with no owner' do
      it 'should calculate wages for the tax year' do
        allow(account).to receive(:owner).and_return(nil)
        form_set.run(account, new_tax_year)
        expect(form_set.wages).to eq(12.0 * (income_account1.gross + income_account2.gross))
      end
    end
    context 'with an owner' do
      it 'should calculate that owner''s wages' do
        allow(account).to receive(:owner).and_return(owner)
        form_set.run(account, new_tax_year)
        expect(form_set.wages).to eq(12.0 * income_account1.gross)
      end
    end
  end

end
