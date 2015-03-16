module Expendable
  extend ActiveSupport::Concern

  def expense(month, amount)
    savings_accounts = scenario.savings_accounts_by_interest_rate
    current = amount
    savings_accounts.each do |account|
      current = debit_account(account, month, current)
      break if current <= 0
    end
    raise "Insufficient funds to debit #{amount}" if current > 0
  end

  private

  def debit_account(account, month, amount)
    starting_balance = account.running_balance(month)
    if starting_balance >= amount
      account.debit(month, amount)
      0
    else
      remaining = amount - starting_balance
      account.debit(month, starting_balance)
      remaining
    end
  end

end
