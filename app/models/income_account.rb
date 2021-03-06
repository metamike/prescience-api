class IncomeAccount < ActiveRecord::Base

  FEDERAL_INCOME_TAX_RATE = 0.2
  SOCIAL_SECURITY_TAX_RATE = 0.062
  MEDICARE_TAX_RATE = 0.0145
  STATE_INCOME_TAX_RATE = 0.08
  STATE_DISABILITY_TAX_RATE = 0.009
  HOME_EQUITY_REDUCTION = 0.8

  TAX_FIELDS = [:federal_income_tax, :social_security_tax, :medicare_tax,
                :state_income_tax, :state_disability_tax]

  belongs_to :scenario
  belongs_to :owner

  has_many :income_account_activities, -> { order(:month) },
                                       after_add: :build_transaction_from_activity

  serialize :starting_month, Month
  serialize :annual_raise, RandomVariable

  validates :owner, presence: true
  validates :name, presence: true
  validates :starting_month, presence: true
  validates :annual_salary, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month < starting_month || income_account_activities.find { |a| a.month == month }
    @transactions[month] ||= {}
    @transactions[month][:gross] ||= (calc_gross(month) / 12.0).round(2)
    @transactions[month][:commuter_benefits] ||= calc_commuter_benefits(month)
    @transactions[month][:pretax_401k_contribution] ||= 0
    @transactions[month][:aftertax_401k_contribution] ||= 0
    @transactions[month][:federal_income_tax] ||= calc_federal_income_tax(month, @transactions[month][:gross])
    @transactions[month][:social_security_tax] ||= calc_social_security_tax(month, @transactions[month][:gross])
    @transactions[month][:medicare_tax] ||= calc_medicare_tax(month, @transactions[month][:gross])
    @transactions[month][:state_income_tax] ||= calc_state_income_tax(month, @transactions[month][:gross])
    @transactions[month][:state_disability_tax] ||= calc_state_disability_tax(month, @transactions[month][:gross])
    @transactions[month][:net] ||= calc_net(month)
  end

  def gross(month)
    @transactions[month] ? @transactions[month][:gross] : 0
  end

  def federal_income_tax(month)
    @transactions[month] ? @transactions[month][:federal_income_tax] : 0
  end

  def state_income_tax(month)
    @transactions[month] ? @transactions[month][:state_income_tax] : 0
  end

  def taxes(month)
    return 0 unless @transactions[month]
    TAX_FIELDS.reduce(0) { |a, f| a + @transactions[month][f] }
  end

  def contributions_to_401k(month)
    return 0 unless @transactions[month]
    (@transactions[month][:pretax_401k_contribution] || 0) + (@transactions[month][:aftertax_401k_contribution] || 0)
  end

  def net(month)
    @transactions[month] ? @transactions[month][:net] : 0
  end

  def record_pretax_401k_contribution(month, amount)
    @transactions[month] ||= {}
    @transactions[month][:pretax_401k_contribution] ||= 0
    @transactions[month][:pretax_401k_contribution] += amount
  end

  def record_aftertax_401k_contribution(month, amount)
    @transactions[month] ||= {}
    @transactions[month][:aftertax_401k_contribution] ||= 0
    @transactions[month][:aftertax_401k_contribution] += amount
  end

  def ytd_401k_contributions(month)
    contributions = 0
    Month.new(month.year, 1).upto(month) { |m| contributions += contributions_to_401k(month) }
    contributions
  end

  def salary(month)
    @annual_salaries[month.year] || 0
  end

  def transact(month)
    raise "No income projected for #{month.to_s}" unless @transactions[month]
    savings_account = scenario.savings_account_by_owner(owner)
    raise "No savings account found for #{owner.name}" unless savings_account
    savings_account.credit(month, @transactions[month][:net])
  end

  def summary(month)
    {
      'income' => {
        'gross' => gross(month),
        'taxes' => taxes(month),
        '401k' => contributions_to_401k(month),
        'net' => net(month)
      }
    }
  end

  private

  def init
    @transactions = {}
    @annual_raises = {}
    @annual_salaries = {}
    self.annual_raise ||= RandomVariable.new(0)
    income_account_activities.each { |a| build_transaction_from_activity(a) }
  end

  def activities_must_be_in_sequence
    current_month = starting_month
    income_account_activities.each do |activity|
      if activity.month != current_month
        errors.add(:income_account_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

  def build_transaction_from_activity(activity)
    @transactions[activity.month] = {}
    ([:gross, :net, :pretax_401k_contribution, :aftertax_401k_contribution] + TAX_FIELDS).each do |field|
      @transactions[activity.month][field] = activity.send(field)
    end
  end

  def calc_gross(month)
    return @annual_salaries[month.year] if @annual_salaries[month.year]
    annual_raise = calc_raise(month.year)
    prior_salary = @annual_salaries[month.prior_year] || annual_salary
    @annual_salaries[month.year] = prior_salary * (1 + annual_raise)
  end

  def calc_commuter_benefits(month)
    account = scenario.commuter_account_by_owner(owner)
    return 0 unless account
    account.project(month)
    account.amount(month)
  end

  def calc_federal_income_tax(month, gross)
    home_equity_account = scenario.home_equity_accounts.find { |a| a.owner == owner && !a.almost_paid_off?(month) }
    rate = home_equity_account ? FEDERAL_INCOME_TAX_RATE * HOME_EQUITY_REDUCTION : FEDERAL_INCOME_TAX_RATE
    ((gross - @transactions[month][:pretax_401k_contribution] - @transactions[month][:commuter_benefits]) * rate).round(2)
  end

  def calc_social_security_tax(month, gross)
    tax_info = scenario.tax_info
    wages = ytd_wages(month)
    if wages < tax_info.social_security_wage_limit(month.year)
      ((gross - @transactions[month][:pretax_401k_contribution] - @transactions[month][:commuter_benefits]) * SOCIAL_SECURITY_TAX_RATE).round(2)
    elsif wages - gross < tax_info.social_security_wage_limit(month.year)
      taxable = tax_info.social_security_wage_limit(month.year) - (wages - gross)
      ((taxable - @transactions[month][:pretax_401k_contribution] - @transactions[month][:commuter_benefits]) * SOCIAL_SECURITY_TAX_RATE).round(2)
    else
      0
    end
  end

  def calc_medicare_tax(month, gross)
    ((gross - @transactions[month][:pretax_401k_contribution] - @transactions[month][:commuter_benefits]) * MEDICARE_TAX_RATE).round(2)
  end

  def calc_state_income_tax(month, gross)
    home_equity_account = scenario.home_equity_accounts.find { |a| a.owner == owner && !a.almost_paid_off?(month) }
    rate = home_equity_account ? STATE_INCOME_TAX_RATE * HOME_EQUITY_REDUCTION : STATE_INCOME_TAX_RATE
    ((gross - @transactions[month][:pretax_401k_contribution] - @transactions[month][:commuter_benefits]) * rate).round(2)
  end

  def calc_state_disability_tax(month, gross)
    tax_info = scenario.tax_info
    wages = ytd_wages(month)
    if wages < tax_info.state_disability_wage_limit(month.year)
      ((gross - @transactions[month][:pretax_401k_contribution] - @transactions[month][:commuter_benefits]) * STATE_DISABILITY_TAX_RATE).round(2)
    elsif wages - gross < tax_info.state_disability_wage_limit(month.year)
      taxable = tax_info.state_disability_wage_limit(month.year) - (wages - gross)
      ((taxable - @transactions[month][:pretax_401k_contribution] - @transactions[month][:commuter_benefits]) * STATE_DISABILITY_TAX_RATE).round(2)
    else
      0
    end
  end

  def calc_net(month)
    @transactions[month][:gross] - (@transactions[month][:pretax_401k_contribution] + @transactions[month][:aftertax_401k_contribution] + TAX_FIELDS.reduce(0) { |a, f| a + @transactions[month][f] })
  end

  def calc_raise(year)
    return 0 if year <= projections_start.year
    @annual_raises[year] ||= annual_raise.sample
  end

  def ytd_wages(month)
    wages = 0
    Month.new(month.year, 1).upto(month) { |m| wages += gross(m) }
    wages
  end

  def projections_start
    income_account_activities.empty? ? starting_month : income_account_activities.last.month.next
  end

end
