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

  # Serialization methods

  def self.dump(value)
    return nil unless value
    {'mean' => value.mean, 'stdev' => value.stdev}.to_json
  end

  def self.load(value)
    return nil unless value
    object = RandomVariable.new
    JSON.load(value).each do |var, val|
      object.send("#{var}=", val)
    end
    object
  end

  private

  def init_dist
    @dist = Rubystats::NormalDistribution.new(@mean, @stdev) if @stdev != 0
  end

end
