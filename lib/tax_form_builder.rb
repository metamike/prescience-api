module TaxFormBuilder

  @form_set ||= TaxFormSet.new

  def self.form_set
    @form_set
  end

  def self.reset
    @form_set = TaxFormSet.new
  end

  def self.constructify(&block)
    raise "Need a block!" unless block_given?

    form_set.instance_eval(&block)
  end

  def self.run(scenario, tax_year)
    form_set.run(scenario, tax_year)
  end

end
