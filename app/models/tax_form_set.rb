class TaxFormSet

  # TODO underscore after 'f'
  FORM_REGEX = /^f[\d\w]+$/

  attr_reader :forms

  def initialize
    @forms = {}
  end

  def run(account, year)
    @account = account
    @tax_year = year
  end

  def form(name, &block)
    form = TaxForm.new(self)
    form.instance_eval(&block) if block_given?
    @forms[name.to_s] = form
  end

  def filing_status(year)
    if income_tax_activities.find { |a| a.year == year }
      income_tax_activities.find { |a| a.year == year }.filing_status
    else
      # TODO support filing statuses
      'single'
    end
  end

  def wages
    if income_tax_activities.find { |a| a.year == year }
      income_tax_activities.find { |a| a.year == year }.wages
    else
      reduce_tax_year do |wages, month|
        wages + @scenario.income_accounts.where(owner_id: @owner.id).reduce(0) { |a, e| a + e.gross(month) }
      end
    end
  end

  def taxable_interest
    if income_tax_activities.find { |a| a.year == year }
      income_tax_activities.find { |a| a.year == year }.taxable_interest
    else
      reduce_tax_year do |interest, month|
        interest + @scenario.savings_accounts.where(owner_id: @owner.id).reduce(0) { |a, e| a + e.interest(month) }
      end
    end
  end

  def taxable_dividends
    if income_tax_activities.find { |a| a.year == year }
      income_tax_activities.find { |a| a.year == year }.taxable_dividends
    else
      reduce_tax_year do |dividends, month|
        dividends + @scenario.mutual_funds.where(owner_id: @owner.id).reduce(0) { |a, e| a + e.taxable_dividends(month) }
      end
    end
  end

  def qualified_dividends
    if income_tax_activities.find { |a| a.year == year }
      income_tax_activities.find { |a| a.year == year }.qualified_dividends
    else
      reduce_tax_year do |dividends, month|
        dividends + @scenario.mutual_funds.where(owner_id: @owner.id).reduce(0) { |a, e| a + e.qualified_dividends(month) }
      end
    end
  end

  def state_income_tax_refund
    raise NotImplementedError
  end

  def prior_year_state_income_taxes
    raise NotImplementedError
  end

  def prior_year_itemized_deductions
    raise NotImplementedError
  end

  private

  def reduce_tax_year
    accum = 0
    Month.new(@tax_year, 1).upto(Month.new(@tax_year, 12)) do |month|
      accum = yield accum, month if block_given?
    end
    accum
  end

  def method_missing(method, *arg)
    if method.to_s =~ FORM_REGEX
      form = method.to_s[1..-1]
      @forms[form] || super
    else
      super
    end
  end

end
