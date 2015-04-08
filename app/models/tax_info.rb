class TaxInfo < ActiveRecord::Base

  has_many :historical_tax_infos, -> { order(:year) },
                                  after_add: :build_data_from_historical

  serialize :social_security_wage_limit_growth_rate, RandomVariable
  serialize :state_disability_wage_limit_growth_rate, RandomVariable
  serialize :annual_401k_contribution_limit_growth_rate, RandomVariable
  serialize :standard_deduction_growth_rate, RandomVariable
  serialize :max_capital_loss_growth_rate, RandomVariable
  serialize :personal_exemption_income_limit_growth_rate, RandomVariable
  serialize :personal_exemption_growth_rate, RandomVariable

  after_initialize :init

  def social_security_wage_limit(year)
    growing_value(year, :social_security_wage_limit)
  end

  def state_disability_wage_limit(year)
    growing_value(year, :state_disability_wage_limit)
  end

  def annual_401k_contribution_limit(year)
    growing_value(year, :annual_401k_contribution_limit)
  end

  def standard_deduction(year, filing_status)
    growing_value(year, :standard_deduction) * (filing_status == 'single' ? 1 : 2)
  end

  def max_capital_loss(year)
    growing_value(year, :max_capital_loss)
  end

  def personal_exemption_income_limit(year, filing_status)
    field = "personal_exemption_income_limit_#{filing_status}".to_sym
    growing_value(year, field, :personal_exemption_income_limit_growth_rate)
  end

  def personal_exemption(year, filing_status)
    growing_value(year, :personal_exemption)
  end

  private

  def init
    @data_by_year = {}
    @starting_year = nil
    historical_tax_infos.each { |i| build_data_from_historical(i) }
  end

  def build_data_from_historical(historical)
    @data_by_year[historical.year] = {
      social_security_wage_limit: historical.social_security_wage_limit,
      state_disability_wage_limit: historical.state_disability_wage_limit,
      annual_401k_contribution_limit: historical.annual_401k_contribution_limit,
      standard_deduction: historical.standard_deduction,
      max_capital_loss: historical.max_capital_loss,
      personal_exemption_income_limit_single: historical.personal_exemption_income_limit_single,
      personal_exemption_income_limit_married: historical.personal_exemption_income_limit_married,
      personal_exemption: historical.personal_exemption
    }
    @starting_year = !@starting_year || historical.year < @starting_year ? historical.year : @starting_year
  end

  def growing_value(year, field, rate_field = nil)
    raise "Cannot calculate value for #{field} for year prior to starting year" if year < @starting_year
    @data_by_year[year] ||= {}
    if @data_by_year[year][field]
      @data_by_year[year][field]
    else
      rate_field ||= "#{field}_growth_rate".to_sym
      @data_by_year[year][field] = (growing_value(year - 1, field, rate_field) * (1 + self.send(rate_field).sample)).round(2)
    end
  end

end
