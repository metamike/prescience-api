class TaxInfo < ActiveRecord::Base

  serialize :social_security_wage_limit_growth_rate, RandomVariable
  serialize :state_disability_wage_limit_growth_rate, RandomVariable
  serialize :annual_401k_contribution_limit_growth_rate, RandomVariable

  validates :starting_year, presence: true, numericality: true

  validates :social_security_wage_limit, presence: true, numericality: true
  validates :state_disability_wage_limit, presence: true, numericality: true
  validates :annual_401k_contribution_limit, presence: true, numericality: true

  after_initialize :init

  def social_security_wage_limit_for_year(year)
    growing_value(year, :social_security_wage_limit)
  end

  def state_disability_wage_limit_for_year(year)
    growing_value(year, :state_disability_wage_limit)
  end

  def annual_401k_contribution_limit_for_year(year)
    growing_value(year, :annual_401k_contribution_limit)
  end

  private

  def init
    @data_by_year = {}
  end

  def growing_value(year, field)
    raise "Cannot calculate #{field} for year prior to starting year" if year < starting_year
    @data_by_year[year] ||= {}
    if @data_by_year[year][field]
      @data_by_year[field]
    elsif year == starting_year
      @data_by_year[field] = self.send(field)
    else
      rate_field = "#{field}_growth_rate".to_sym
      @data_by_year[field] = (growing_value(year - 1, field) * (1 + self.send(rate_field).sample)).round(2)
    end
  end

end
