class SavingsAccount < Vector

  validates :interest_rate, presence: true
  validates :starting_balance, numericality: true, presence: true

end
