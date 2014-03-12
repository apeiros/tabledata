# encoding: utf-8

require 'table_data/table'
require 'table_data/coerced_row'

module TableData

  class CustomTable < Table
    class << self
      attr_reader :definition
    end

    attr_reader :table_errors, :original_data, :original_rows

    def initialize(options)
      columns = self.class.definition.columns
      options = options.merge(accessors: columns.map(&:accessor))

      super(options)

      @table_errors  = []
      @original_data = @data
      @original_rows = @rows

      @rows = @rows.map.with_index { |row, row_index|
        column_errors = {}
        coerced_values = *row.map.with_index { |value, column_index|
          column = columns[column_index]
          value, errors = column.coerce(value)
          column_errors[column.accessor] = errors
        }
        row_errors = []
        CoercedRow.new(self, row_index, coerced_values, column_errors, row_errors)
      }
      @data = @rows.map(&:to_a)
    end

    def <<(row)
      columns       = self.class.definition.columns
      index         = @data.size
      column_errors = {}

      begin
        row = row.to_ary
      rescue NoMethodError
        raise ArgumentError, "Row must be provided as Array or respond to `to_ary`, but got #{row.class} in row #{index}" unless row.respond_to?(:to_ary)
        raise
      end
      raise InvalidColumnCount.new(index, row.size, column_count) if @data.first && row.size != @data.first.size

      if index > 0 || !@has_headers
        coerced_values = *row.map.with_index { |value, column_index|
          column                         = columns[column_index]
          value, errors                  = column.coerce(value)
          column_errors[column.accessor] = errors

          value
        }
        row_errors = []
      else
        coerced_values = row.dup
        row_errors     = []
      end

      @original_data << row
      @original_rows << Row.new(self, index, row)
      @data << coerced_values
      @rows << CoercedRow.new(self, index, coerced_values, column_errors, row_errors)

      self
    end

    def valid?
      @table_errors.empty? && @rows.all?(&:valid?)
    end
  end
end
