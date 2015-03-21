class TaxFormSet

  FORM_REGEX = /^f[\d\w]+$/

  attr_reader :forms

  def initialize
    @forms = {}
  end

  def run(scenario, tax_year)
    @scenario = scenario
    @tax_year = tax_year
    self
  end

  def form(name, &block)
    form = TaxForm.new(self)
    form.instance_eval(&block) if block_given?
    @forms[name.to_s] = form
  end

  def federal_income_tax_net
    # find the cell w/ this name
  end

  def state_income_tax_net
  end

  def wages
  end

  private

  def method_missing(method, *arg)
    if method.to_s =~ FORM_REGEX
      form = method.to_s[1..-1]
      @forms[form] || super
    else
      super
    end
  end

end
