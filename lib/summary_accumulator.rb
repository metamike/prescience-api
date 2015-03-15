class SummaryAccumulator

  def initialize
    @summary = {}
  end

  def merge(summary)
    return unless summary
    @summary.merge!(summary) { |key, v1, v2| merge_value(key, v1, v2) }
  end

  def summary
    new_summary = {}
    @summary.each do |k, v|
      new_summary[k] = float(v)
    end
    new_summary
  end

  private

  def float(val)
    if val.is_a? Hash
      new_hash = {}
      val.each do |k, v|
        new_hash[k] = float(v)
      end
      new_hash
    else
      val.to_f
    end
  end

  def merge_value(key, val1, val2)
    if val1.is_a?(Hash) && !val2.is_a?(Hash) || !val1.is_a?(Hash) && val2.is_a?(Hash)
      raise "Mismatched type for #{key}, #{val1.class} and #{val2.class}"
    end

    if val1.is_a? Hash
      val1.merge(val2) { |key, v1, v2| merge_value(key, v1, v2) }
    elsif val1.is_a? Numeric
      val1 + val2
    else
      raise "Don't know how to merge type #{val1.class}"
    end
  end

end
