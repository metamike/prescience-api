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

  def self.run(scenario, owner, tax_year)
    form_set.run(scenario, owner, tax_year)
  end

end

Dir['./lib/tax_forms/*.rb'].each { |f| require f }
