require './lib/month'

FactoryGirl.define do
  factory :savings_account do
    starting_balance 25000.10
    starting_month Month.new(2014, 9)
    interest_rate 0.0028

    scenario
  end

end
