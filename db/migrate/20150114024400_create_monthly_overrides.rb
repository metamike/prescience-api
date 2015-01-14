class CreateMonthlyOverrides < ActiveRecord::Migration
  def change
    create_table :monthly_overrides do |t|
      t.integer :vector_id
      t.string  :vector_type
      t.string  :month

      t.timestamps null: false
    end
    add_money :monthly_overrides, :amount
  end
end

