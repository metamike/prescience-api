# Normally-distributed random variable
class RandomVariable

  attr_reader :mean, :stdev

  def initialize(mean = 0, stdev = 0)
    @mean, @stdev = mean, stdev
    init_dist
  end

  def mean=(mean)
    @mean = mean
    init_dist 
  end

  def stdev=(stdev)
    @stdev = stdev || 0
    init_dist
  end

  def sample
    @stdev == 0 ? @mean : @dist.rng
  end

  def to_json
    debugger
    {'mean' => @mean, 'stdev' => @stdev}.to_json
  end

  def from_json!(string)
    debugger
    JSON.load(string).each do |var, val|
      self.instance_variable_set(var, val)
    end
    init_dist
  end

  private

  def init_dist
    @dist = Rubystats::NormalDistribution.new(@mean, @stdev) if @stdev != 0
  end

end
