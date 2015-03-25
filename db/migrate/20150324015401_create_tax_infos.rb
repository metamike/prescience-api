class CreateTaxInfos < ActiveRecord::Migration
  def change
    create_table :tax_infos do |t|
      t.integer :starting_year

      # payroll taxes
      t.decimal :social_security_wage_limit, precision: 9, scale: 2
      t.string  :social_security_wage_limit_growth_rate
      t.decimal :state_disability_wage_limit, precision: 9, scale: 2
      t.string  :state_disability_wage_limit_growth_rate

      t.references :scenario, index: true

      t.timestamps null: false
    end
  end
end
