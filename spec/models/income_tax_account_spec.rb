require 'rails_helper'

describe IncomeTaxAccount, type: :model do

  let(:account) { build(:income_tax_account, :with_activity) }
  let(:form_set) { double(TaxFormSet) }
  let(:f1040) { double(TaxForm) }
  let(:federal_refund) { BigDecimal.new('4000') }
  let(:ca540) { double(TaxForm) }
  let(:state_refund) { BigDecimal.new('-1200') }

  before :each do
    allow(TaxFormBuilder).to receive(:form_set).and_return(form_set)
    allow(form_set).to receive(:run)
    allow(form_set).to receive(:f1040).and_return(f1040)
    allow(f1040).to receive(:federal_income_tax_refund).and_return(federal_refund)
    allow(form_set).to receive(:ca540).and_return(ca540)
    allow(ca540).to receive(:state_income_tax_refund).and_return(state_refund)
  end

  context 'validations' do
    it { should validate_inclusion_of(:filing_status).in_array(%w(single married)) }
  end

  context 'with historicals' do
    it 'should reference the historical' do
      month = Month.new(account.income_tax_activities.first.year + 1, IncomeTaxAccount::TAX_MONTH)
      expect(account.federal_income_taxes(month)).to eq(-account.income_tax_activities.first.federal_income_tax_refund)
      expect(account.state_income_taxes(month)).to eq(-account.income_tax_activities.first.state_income_tax_refund)
    end
  end

  describe '#project' do
    context 'on a non-tax month' do
      it 'should do nothing' do
        month = Month.new(1000, 1)
        account.project(month)
        expect(account.federal_income_taxes(month)).to eq(0)
        expect(account.state_income_taxes(month)).to eq(0)
      end
    end
    context 'without historicals' do
      it 'should consult the TaxFormSet' do
        month = Month.new(account.income_tax_activities.first.year + 2, IncomeTaxAccount::TAX_MONTH)
        account.project(month)
        expect(account.federal_income_taxes(month)).to eq(-federal_refund)
        expect(account.state_income_taxes(month)).to eq(-state_refund)
      end
    end
  end

  describe '#transact' do
    it 'should sum federal and state income taxes' do
      month = Month.new(account.income_tax_activities.first.year + 2, IncomeTaxAccount::TAX_MONTH)
      allow(account).to receive(:expense)
      expect(account).to receive(:expense).with(month, -(federal_refund + state_refund))
      account.project(month)
      account.transact(month)
    end
  end

  describe '#summary' do
    it 'should return default data' do
      month = Month.new(account.income_tax_activities.first.year + 1, IncomeTaxAccount::TAX_MONTH)
      summary = {'income taxes' => {'federal income taxes' => 0, 'state income taxes' => 0}}
      expect(account.summary(month.next)).to eq(summary)
    end
    it 'should aggregate federal and state returns' do
      month = Month.new(account.income_tax_activities.first.year + 1, IncomeTaxAccount::TAX_MONTH)
      summary = {'income taxes' => {'federal income taxes' => account.federal_income_taxes(month), 'state income taxes' => account.state_income_taxes(month)}}
      expect(account.summary(month)).to eq(summary)
    end
  end

end
