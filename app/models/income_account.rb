class IncomeAccount < ActiveRecord::Base

  belongs_to :scenario

  has_one :savings_account

  has_many :income_account_activities, -> { order(:month) },
                                       after_add: :transactions_from_activity

  serialize :starting_month
  serialize :annual_raise, RandomVariable

  validates :name, presence: true
  validates :starting_month, presence: true
  validates :annual_gross, presence: true, numericality: true

  validate :activities_must_be_in_sequence

  after_initialize :init

  def project(month)
    return if month < starting_month
    raise "Need at least one savings account to run income" unless savings_account
    gross = @transactions[month] || calc_gross(month) / 12.0
    gross = gross.round(2)
    transact(month, gross)
  end

  def gross(month)
    @transactions[month] || 0
  end

  def raise(month)
    @annual_raises[month.year] || 0
  end

  private

  def init
    @transactions = {}
    @annual_raises = {}
    @annual_grosses = {}
    self.annual_raise ||= RandomVariable.new(0)
  end

  def calc_gross(month)
    return 0 if month < starting_month
    return @annual_grosses[month.year] if @annual_grosses[month.year]
    annual_raise = calc_raise(month.year)
    prior = @annual_grosses[month.prior_year] || annual_gross
    @annual_grosses[month.year] = prior * (1 + annual_raise)
  end

  def calc_raise(year)
    return 0 if year <= projections_start.year
    @annual_raises[year] ||= annual_raise.sample
  end

  def activities_must_be_in_sequence
    current_month = starting_month
    income_account_activities.each do |activity|
      if activity.month != current_month
        errors.add(:income_account_activities, "activity #{activity.month} is out of sequence")
        break
      end
      current_month = current_month.next
    end
  end

  def projections_start
    income_account_activities.empty? ? starting_month : income_account_activities.last.month.next
  end

  def transactions_from_activity(activity)
    @transactions[activity.month] = activity.gross
  end

  def transact(month, gross)
    savings_account.credit(month, gross)
    @transactions[month] = gross
  end

end
