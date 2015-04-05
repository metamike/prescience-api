class TaxFormSet

  # TODO underscore after 'f'
  FORM_REGEX = /^f[\d\w]+$/

  attr_reader :forms, :tax_year

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

  def filing_status
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.filing_status
    else
      @account.filing_status
    end
  end

  def wages
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.wages
    else
      reduce_tax_year do |wages, month|
        if @account.owner
          wages + @account.scenario.income_accounts.select { |a| a.owner_id == @account.owner_id }.reduce(0) { |a, e| a + e.gross(month) }
        else
          wages + @account.scenario.income_accounts.reduce(0) { |a, e| a + e.gross(month) }
        end
      end
    end
  end

  def taxable_interest
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.taxable_interest
    else
      reduce_tax_year do |interest, month|
        if @account.owner
          interest + @account.scenario.savings_accounts.select { |a| a.owner_id == @account.owner_id }.reduce(0) { |a, e| a + e.interest(month) }
        else
          interest + @account.scenario.income_accounts.reduce(0) { |a, e| a + e.interest(month) }
        end
      end
    end
  end

  def taxable_dividends
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.taxable_dividends
    else
      reduce_tax_year do |dividends, month|
        if @account.owner
          dividends + @account.scenario.mutual_funds.select { |a| a.owner_id == @account.owner_id }.reduce(0) { |a, e| a + e.taxable_dividends(month) }
        else
          dividends + @account.scenario.mutual_funds.reduce(0) { |a, e| a + e.taxable_dividends(month) }
        end
      end
    end
  end

  def qualified_dividends
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.qualified_dividends
    else
      reduce_tax_year do |dividends, month|
        if @account.owner
          dividends + @account.scenario.mutual_funds.select { |a| a.owner_id == @account.owner_id }.reduce(0) { |a, e| a + e.qualified_dividends(month) }
        else
          dividends + @account.scenario.mutual_funds.reduce(0) { |a, e| a + e.qualified_dividends(month) }
        end
      end
    end
  end

  def state_income_tax_refund
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      -@account.income_tax_activities.find { |a| a.year == @tax_year }.state_income_tax_owed
    else
      -@account.state_income_tax_owed(@tax_year - 1)
    end
  end

  def prior_year_state_income_taxes
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.state_income_tax
    else
      @account.state_income_tax(@tax_year - 1)
    end
  end

  def prior_year_capital_net
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.capital_net
    else
      @account.capital_net(@tax_year - 1)
    end
  end

  def prior_year_adjusted_gross_income
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.adjusted_gross_income
    else
      @account.adjusted_gross_income(@tax_year - 1)
    end
  end

  def prior_year_itemized_deductions
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.federal_itemized_deductions
    else
      @account.federal_itemized_deductions(@tax_year - 1)
    end
  end

  def short_term_capital_net
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.short_term_capital_net
    else
      if @account.owner
        @account.scenario.mutual_funds.select { |a| a.owner_id == @account.owner_id }.reduce(0) { |a, e| a + e.short_term_net(@tax_year) }
      else
        @account.scenario.mutual_funds.reduce(0) { |a, e| a + e.short_term_net(@tax_year) }
      end
    end
  end

  def short_term_capital_net
    if @account.income_tax_activities.find { |a| a.year == @tax_year }
      @account.income_tax_activities.find { |a| a.year == @tax_year }.long_term_capital_net
    else
      if @account.owner
        @account.scenario.mutual_funds.select { |a| a.owner_id == @account.owner_id }.reduce(0) { |a, e| a + e.long_term_net(@tax_year) }
      else
        @account.scenario.mutual_funds.reduce(0) { |a, e| a + e.long_term_net(@tax_year) }
      end
    end
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
