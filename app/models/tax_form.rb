class TaxForm

  CELL_REGEX = /^c[\d\w]+$/

  def initialize(form_set)
    @form_set = form_set
    @cells_by_ref = {}
    @cells_by_name = {}
  end

  def cell(ref, name = nil, value)
    @cells_by_ref[ref.to_s] = value
    @cells_by_name[name.to_s] = value if name
    self
  end

  private

  def method_missing(method, *args)
    formulate_cell(method)
  end

  def formulate_cell(ref)
    value = cell_value(ref.to_s)
    return @form_set.send(ref) unless value   # try parent

    if value.respond_to?(:call)
      self.instance_eval &value
    elsif value.is_a? Symbol
      form_set.send(value)
    else
      value
    end
  end

  def cell_value(name)
    if @cells_by_name.has_key?(name)
      @cells_by_name[name]
    elsif name =~ CELL_REGEX && @cells_by_ref.has_key?(name.to_s[1..-1])
      @cells_by_ref[name.to_s[1..-1]]
    else
      nil
    end
  end

end
