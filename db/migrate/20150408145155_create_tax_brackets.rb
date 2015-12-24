class CreateTaxBrackets < ActiveRecord::Migration
  def change
    create_table :tax_brackets do |t|
      t.references :historical_tax_info

      t.string  :type
      t.string  :filing_status
      t.decimal :lower_bound, precision: 9, scale: 2
      t.decimal :slope,       precision: 4, scale: 3
      t.decimal :intercept,   precision: 8, scale: 2
    end
  end
end
