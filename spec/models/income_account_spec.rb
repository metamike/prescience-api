require 'rails_helper'

describe IncomeAccount, :type => :model do

  let(:activity) { build(:income_account_activity, month: account.starting_month) }
  let(:scenario) { mock_model(Scenario) }
  let(:tax_info) { instance_double(TaxInfo) }
  let(:account)  { build(:income_account, scenario: scenario) }
  let(:home_equity_account) { instance_double(HomeEquityAccount) }

  before :each do
    allow(scenario).to receive(:home_equity_accounts).and_return([])
    allow(scenario).to receive(:tax_info).and_return(tax_info)
    allow(scenario).to receive(:commuter_account_by_owner)
    allow(tax_info).to receive(:social_security_wage_limit).and_return(0)
    allow(tax_info).to receive(:state_disability_wage_limit).and_return(0)
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:starting_month) }
    it { should validate_presence_of(:annual_salary) }
    it { should validate_numericality_of(:annual_salary) }
    it { should validate_presence_of(:owner) }

    let(:activity_good) { build(:income_account_activity, month: activity.month.next) }
    let(:activity_bad) { build(:income_account_activity, month: activity.month.next.next) }

    it 'should fail if activities are out of order' do
      account.income_account_activities << activity
      expect(account.valid?).to be(true)
      account.income_account_activities << activity_bad
      expect(account.valid?).to be(false)
    end

    it 'should validate that activities are in order' do
      account.income_account_activities << activity
      account.income_account_activities << activity_good
      expect(account.valid?).to be(true)
    end
  end

  describe '#project' do

    it 'should return default values for a non-projected month' do
      expect(account.gross(account.starting_month.next)).to eq(0)
      expect(account.taxes(account.starting_month.next)).to eq(0)
      expect(account.net(account.starting_month.next)).to eq(0)
    end

    context 'with historicals' do
      it 'should use those values' do
        account.income_account_activities << activity
        account.project(activity.month)
        expect(account.gross(activity.month)).to eq(activity.gross)
        expect(account.taxes(activity.month)).to eq(
          activity.federal_income_tax + activity.social_security_tax + activity.medicare_tax +
            activity.state_income_tax + activity.state_disability_tax
        )
        expect(account.net(activity.month)).to eq(activity.net)
      end
    end

    context 'with no mortgage' do
      it 'should use a higher tax rate' do
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.net(account.starting_month)).to eq(account.gross(account.starting_month) - tax)
      end
    end

    context 'with a mortgage owned by someone else' do
      it 'should not impact taxes' do
        allow(home_equity_account).to receive(:owner).and_return(nil)
        allow(home_equity_account).to receive(:almost_paid_off?).and_return(false)
        allow(scenario).to receive(:home_equity_accounts).and_return([home_equity_account])
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.net(account.starting_month)).to eq(account.gross(account.starting_month) - tax)
      end
    end

    context 'with a mortgage close to being paid' do
      it 'should use a higher tax rate' do
        allow(home_equity_account).to receive(:owner).and_return(account.owner)
        allow(home_equity_account).to receive(:almost_paid_off?).and_return(true)
        allow(scenario).to receive(:home_equity_accounts).and_return([home_equity_account])
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.net(account.starting_month)).to eq(account.gross(account.starting_month) - tax)
      end
    end

    context 'with a mortgage not close to being paid' do
      it 'should use a lower tax rate' do
        allow(home_equity_account).to receive(:owner).and_return(account.owner)
        allow(home_equity_account).to receive(:almost_paid_off?).and_return(false)
        allow(scenario).to receive(:home_equity_accounts).and_return([home_equity_account])
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::HOME_EQUITY_REDUCTION * IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::HOME_EQUITY_REDUCTION * IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.net(account.starting_month)).to eq(account.gross(account.starting_month) - tax)
      end
    end

    context 'well before social security wage limit' do
      it 'should deduct social security tax' do
        allow(tax_info).to receive(:social_security_wage_limit).and_return(account.annual_salary)
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::SOCIAL_SECURITY_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.net(account.starting_month)).to eq(account.gross(account.starting_month) - tax)
      end
    end

    context 'coming up on social security wage limit' do
      it 'should deduct partial social security tax' do
        allow(tax_info).to receive(:social_security_wage_limit).and_return(account.annual_salary * 1.5 / 12)
        account.project(account.starting_month)
        account.project(account.starting_month.next)
        expect(account.gross(account.starting_month.next)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (0.5 * IncomeAccount::SOCIAL_SECURITY_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month.next)).to eq(tax)
        expect(account.net(account.starting_month.next)).to eq(account.gross(account.starting_month.next) - tax)
      end
    end

    context 'at start of a new year' do
      let(:month) { build(:month, year: account.starting_month.year, month: 12) }
      it 'should withhold social security and state disability taxes' do
        allow(tax_info).to receive(:social_security_wage_limit).with(account.starting_month.year).and_return(account.annual_salary * 0.5 / 12)
        allow(tax_info).to receive(:state_disability_wage_limit).with(account.starting_month.year).and_return(account.annual_salary * 0.5 / 12)
        allow(tax_info).to receive(:social_security_wage_limit).with(account.starting_month.year + 1).and_return(account.annual_salary * 1.5 / 12)
        allow(tax_info).to receive(:state_disability_wage_limit).with(account.starting_month.year + 1).and_return(account.annual_salary * 1.5 / 12)
        account.starting_month = month
        account.project(month)
        account.project(month.next)
        expect(account.gross(month.next)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::SOCIAL_SECURITY_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_DISABILITY_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(month.next)).to eq(tax)
        expect(account.net(month.next)).to eq(account.gross(month.next) - tax)
      end
    end

    context 'well before state disability wage limit' do
      it 'should deduct state disability tax' do
        allow(tax_info).to receive(:state_disability_wage_limit).and_return(account.annual_salary)
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_DISABILITY_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.net(account.starting_month)).to eq(account.gross(account.starting_month) - tax)
      end
    end

    context 'coming up on state disability wage limit' do
      it 'should deduct partial state disability tax' do
        allow(tax_info).to receive(:state_disability_wage_limit).and_return(account.annual_salary * 1.5 / 12)
        account.project(account.starting_month)
        account.project(account.starting_month.next)
        expect(account.gross(account.starting_month.next)).to eq((account.annual_salary / 12.0).round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * account.annual_salary / 12.0).round(2)
        tax += (0.5 * IncomeAccount::STATE_DISABILITY_TAX_RATE * account.annual_salary / 12.0).round(2)
        expect(account.taxes(account.starting_month.next)).to eq(tax)
        expect(account.net(account.starting_month.next)).to eq(account.gross(account.starting_month.next) - tax)
      end
    end

    context 'with pretax 401(k) contributions' do
      it 'should deduct them from the gross' do
        allow(tax_info).to receive(:social_security_wage_limit).and_return(account.annual_salary)
        allow(tax_info).to receive(:state_disability_wage_limit).and_return(account.annual_salary)
        contribution = (account.annual_salary / 12 / 2.0).round(2)
        monthly = account.annual_salary / 12.0
        account.record_pretax_401k_contribution(account.starting_month, contribution)
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq(monthly.round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::SOCIAL_SECURITY_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::STATE_DISABILITY_TAX_RATE * (monthly - contribution)).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.contributions_to_401k(account.starting_month)).to eq(contribution)
        expect(account.net(account.starting_month)).to eq(monthly.round(2) - tax - contribution)
      end
    end

    context 'with aftertax 401(k) contributions' do
      it 'should not deduct them from the gross' do
        allow(tax_info).to receive(:social_security_wage_limit).and_return(account.annual_salary)
        allow(tax_info).to receive(:state_disability_wage_limit).and_return(account.annual_salary)
        contribution = (account.annual_salary / 12 / 2.0).round(2)
        monthly = account.annual_salary / 12.0
        account.record_aftertax_401k_contribution(account.starting_month, contribution)
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq(monthly.round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * monthly).round(2)
        tax += (IncomeAccount::SOCIAL_SECURITY_TAX_RATE * monthly).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * monthly).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * monthly).round(2)
        tax += (IncomeAccount::STATE_DISABILITY_TAX_RATE * monthly).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.contributions_to_401k(account.starting_month)).to eq(contribution)
        expect(account.net(account.starting_month)).to eq(monthly.round(2) - tax - contribution)
      end
    end

    context 'with commuter benefits' do
      let(:commuter_account) { instance_double(ExpenseAccount) }
      it 'should count them as pretax deductions' do
        monthly = account.annual_salary / 12.0
        allow(tax_info).to receive(:social_security_wage_limit).and_return(account.annual_salary)
        allow(tax_info).to receive(:state_disability_wage_limit).and_return(account.annual_salary)
        allow(scenario).to receive(:commuter_account_by_owner).with(account.owner).and_return(commuter_account)
        expect(commuter_account).to receive(:project).with(account.starting_month)
        contribution = (monthly / 10.0).round(2)
        allow(commuter_account).to receive(:amount).with(account.starting_month).and_return(contribution)
        account.project(account.starting_month)
        expect(account.gross(account.starting_month)).to eq(monthly.round(2))
        tax = (IncomeAccount::FEDERAL_INCOME_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::SOCIAL_SECURITY_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::MEDICARE_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::STATE_INCOME_TAX_RATE * (monthly - contribution)).round(2)
        tax += (IncomeAccount::STATE_DISABILITY_TAX_RATE * (monthly - contribution)).round(2)
        expect(account.taxes(account.starting_month)).to eq(tax)
        expect(account.net(account.starting_month)).to eq(monthly.round(2) - tax)
      end
    end

    context 'with annual raise' do

      let(:account) { build(:income_account, :with_raise, scenario: scenario) }

      it 'should account for an annual raise' do
        current = account.starting_month
        0.upto(24) do |i|
          account.project(current)
          rate = (1 + account.annual_raise.mean) ** current.year_diff(account.starting_month)
          expect(account.gross(current)).to eq((account.annual_salary * rate / 12.0).round(2))
          current = current.next
        end
      end

      it 'should begin the raise process only after historicals' do
        current = account.starting_month
        18.times do   # makes sure it skips a year
          activity = build(:income_account_activity, month: current)
          account.income_account_activities << activity
          current = current.next
        end
        account.project(current)
        expect(account.gross(current)).to eq((account.annual_salary / 12.0).round(2))
        loop do
          current = current.next
          account.project(current)
          break if current.year != account.income_account_activities.last.month.year
        end
        expect(account.gross(current)).to eq((account.annual_salary * (1 + account.annual_raise.mean) / 12.0).round(2))
      end

    end

    context 'with uncertain raise' do

      let(:account) { build(:income_account, :uncertain_raise, scenario: scenario, starting_month: Month.new(2014, 12)) }
      let(:rand_values) { [0.0007575949881074517, -0.0001] }

      it 'should sample from a normal distribution to determine raises' do
        allow(account.annual_raise).to receive(:sample).and_return(*rand_values)
        month = account.starting_month
        account.project(month)
        expect(account.gross(month)).to eq((account.annual_salary / 12.0).round(2))
        month = month.next
        account.project(month)
        expect(account.gross(month)).to eq(((1 + rand_values[0]) * account.annual_salary / 12.0).round(2))
      end
    end

  end

  describe '#transact' do

    let(:account) { build(:income_account, scenario: scenario) }
    let(:savings) { instance_double(SavingsAccount) }

    before :each do
      allow(savings).to receive(:credit)
    end

    context 'when called before projecting' do
      it 'should fail' do
        allow(scenario).to receive(:savings_account_by_owner).and_return(savings)
        expect { account.transact(account.starting_month) }.to raise_error
      end
    end

    context 'with no savings account' do
      it 'should fail' do
        allow(scenario).to receive(:savings_account_by_owner).and_return(nil)
        account.project(account.starting_month)
        expect { account.transact(account.starting_month) }.to raise_error
      end
    end

    context 'with a savings account' do
      it 'should credit the savings account' do
        allow(scenario).to receive(:savings_account_by_owner).with(account.owner).and_return(savings)
        account.project(account.starting_month)
        expect(savings).to receive(:credit).with(account.starting_month, account.net(account.starting_month))
        account.transact(account.starting_month)
      end
    end

  end

  describe '#summary' do

    let(:account) { build(:income_account, scenario: scenario) }

    it 'should return zero when not projected' do
      expected = {'income' => {'gross' => 0, 'taxes' => 0, '401k' => 0, 'net' => 0}}
      expect(account.summary(account.starting_month)).to eq(expected)
    end

    it 'should return income summary when projected' do
      account.project(account.starting_month)
      expected = {'income' => {
        'gross' => account.gross(account.starting_month),
        'taxes' => account.taxes(account.starting_month),
        '401k' => account.contributions_to_401k(account.starting_month),
        'net' => account.net(account.starting_month)
      }}
      expect(account.summary(account.starting_month)).to eq(expected)
    end

  end

end

