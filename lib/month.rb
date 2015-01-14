class Month
  include Comparable

  attr_accessor :year, :month

  def initialize(year, month)
    @year = year
    @month = month
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
    if month < 12
      Month.new(year, month + 1)
    else
      Month.new(year + 1, 1)
    end
  end

  def <=>(other)
    @year == other.year ? @month <=> other.month : @year <=> other.year
  end

  def to_s
    "#{'%04d' % year}-#{'%02d' % month}"
  end

end
