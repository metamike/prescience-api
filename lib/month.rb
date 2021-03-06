class Month
  include Comparable

  attr_accessor :year, :month

  def initialize(year = nil, month = nil)
    today = Time.zone.now
    @year = year || today.year
    @month = month || today.month
  end

  def self.parse(string)
    raise "Invalid month #{string}" unless string =~ /^\d{4}-\d{2}$/
    m = string.match(/^(\d{4})-(\d{2})$/)
    Month.new(m[1].to_i, m[2].to_i)
  end

  def upto(month)
    current = self
    while true
      break if current > month
      yield current
      current = current.next
    end
  end

  def next
    month < 12 ? Month.new(year, month + 1) : Month.new(year + 1, 1)
  end

  def prior
    month > 1 ? Month.new(year, month - 1) : Month.new(year - 1, 12)
  end

  def prior_year
    year - 1
  end

  def ==(other)
    return false unless other
    @year == other.year && @month == other.month
  end
  alias_method :eql?, :==

  def <=>(other)
    return nil unless other
    @year == other.year ? @month <=> other.month : @year <=> other.year
  end

  def -(other)
    (self.year * 12 + self.month - 1) - (other.year * 12 + other.month - 1)
  end

  def year_diff(other)
    self.year - other.year
  end

  def end_of_quarter?
    @month % 3 == 0
  end

  def hash
    to_s.hash
  end

  def to_s
    "#{'%04d' % year}-#{'%02d' % month}"
  end

  # Serialization methods

  def self.dump(value)
    return nil unless value
    {'year' => value.year, 'month' => value.month}.to_json
  end

  def self.load(value)
    return nil unless value
    json = JSON.load(value)
    Month.new(json['year'], json['month'])
  end

end
