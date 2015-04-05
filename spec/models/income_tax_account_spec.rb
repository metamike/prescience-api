require 'rails_helper'

describe IncomeTaxAccount, type: :model do

  let(:account) { build(:income_tax_account, :with_activity) }
  let(:form_set) { double(TaxFormSet) }
  let(:f1040) { double(TaxForm) }
  let(:itemized) { BigDecimal.new('9000') }
  let(:agi) { BigDecimal.new('50000') }
  let(:federal_tax) { BigDecimal.new('12000') }
  let(:federal_owed) { BigDecimal.new('-4000') }
  let(:f1040d) { double(TaxForm) }
  let(:capital_net) { BigDecimal.new('500') }
  let(:ca540) { double(TaxForm) }
  let(:state_tax) { BigDecimal.new('6000') }
  let(:state_owed) { BigDecimal.new('1200') }

  before :each do
    allow(TaxFormBuilder).to receive(:form_set).and_return(form_set)
    allow(form_set).to receive(:run)
    allow(form_set).to receive(:f1040).and_return(f1040)
    allow(f1040).to receive(:itemized_deductions).and_return(itemized)
    allow(f1040).to receive(:adjusted_gross_income).and_return(agi)
    allow(f1040).to receive(:federal_income_tax).and_return(federal_tax)
    allow(f1040).to receive(:federal_income_tax_owed).and_return(federal_owed)
    allow(form_set).to receive(:f1040d).and_return(f1040d)
    allow(f1040d).to receive(:capital_net).and_return(capital_net)
    allow(form_set).to receive(:ca540).and_return(ca540)
    allow(ca540).to receive(:state_income_tax).and_return(state_tax)
    allow(ca540).to receive(:state_income_tax_owed).and_return(state_owed)
  end

  context 'validations' do
    it { should validate_inclusion_of(:filing_status).in_array(%w(single married)) }
  end

  context 'with historicals' do
    it 'should reference the historical' do
      month = Month.new(account.income_tax_activities.first.year + 1, IncomeTaxAccount::TAX_MONTH)
      expect(account.federal_income_tax_owed(month.year - 1)).to eq(account.income_tax_activities.first.federal_income_tax_owed)
      expect(account.state_income_tax_owed(month.year - 1)).to eq(account.income_tax_activities.first.state_income_tax_owed)
    end
  end

  describe '#project' do
    context 'without historicals' do
      it 'should consult the TaxFormSet' do
        month = Month.new(account.income_tax_activities.first.year + 2, IncomeTaxAccount::TAX_MONTH)
        account.project(month)
        expect(account.federal_income_tax_owed(month.year - 1)).to eq(federal_owed)
        expect(account.state_income_tax_owed(month.year - 1)).to eq(state_owed)
      end
    end
  end

  describe '#transact' do
    it 'should sum federal and state income taxes' do
      month = Month.new(account.income_tax_activities.first.year + 2, IncomeTaxAccount::TAX_MONTH)
      allow(account).to receive(:expense)
      expect(account).to receive(:expense).with(month, federal_owed+ state_owed)
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
      summary = {'income taxes' => {'federal income taxes' => account.federal_income_tax_owed(month.year - 1), 'state income taxes' => account.state_income_tax_owed(month.year - 1)}}
      expect(account.summary(month)).to eq(summary)
    end
  end

end
