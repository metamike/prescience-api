class ExpenseAccountActivity < ActiveRecord::Base

  belongs_to :expense_account

  serialize :month

  validates :month, presence: true
  validates :amount, presence: true, numericality: true

end
