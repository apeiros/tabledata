# encoding: utf-8

module Tables
  class CoercingRow < Row
    def initialize(table, index, data, coercions)
      @coercions  = coercions
      super(table, index, data.map.with_index { |value, col| coerce(col, value) })
    end

    def coerce(column, value)
      coercer = @coercions[column]
      coercer ? coercer.call(value) : value
    end
  end
end
