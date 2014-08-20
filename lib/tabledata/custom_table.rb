# encoding: utf-8

require 'tabledata/table'
require 'tabledata/coerced_row'

module Tabledata

  class CustomTable < Table
    class << self
      attr_reader :definition
    end

    def self.table_name
      @definition.table_name
    end

    def self.identifier
      @definition.identifier
    end

    def self.from_file(path, options=nil)
      options        ||= {}
      options[:name] ||= @definition.table_name

      super(path, options)
    end

    attr_reader :table_errors, :original_data, :original_rows

    def initialize(options)
      definition = self.class.definition
      columns    = definition.columns
      options    = options.merge(accessors: columns.map(&:accessor), name: definition.table_name) { |key,v1,v2|
        if key == :accessors
          raise "Can't handle reordering of accessors - don't redefine accessors in CustomTables for now"
        elsif key == :name
          v1 || v2
        else
          raise "unreachable"
        end
      }

      super(options)

      @table_errors  = []
      @original_data = @data
      @original_rows = @rows

      @rows = @rows.map.with_index { |row, row_index|
        column_errors = {}
        coerced_values = *row.map.with_index { |value, column_index|
          column = columns[column_index]
          value, errors = column.coerce(value)
          column_errors[column.accessor] = errors unless errors.empty?
        }
        row_errors = []
        CoercedRow.new(self, row_index, coerced_values, column_errors, row_errors)
      }
      @data = @rows.map(&:to_a)
    end

    def <<(raw_row)
      definition         = self.class.definition
      width              = definition.columns.size
      sourced_columns    = definition.sourced_columns
      source_indices     = definition.source_indices
      calculated_columns = definition.calculated_columns
      index              = @data.size
      column_errors      = {}

      begin
        raw_row = raw_row.to_ary
      rescue NoMethodError
        raise ArgumentError, "Row must be provided as Array or respond to `to_ary`, but got #{raw_row.class} in row #{index}" unless raw_row.respond_to?(:to_ary)
        raise
      end
      # raise InvalidColumnCount.new(index, raw_row.size, column_count) if @data.first && raw_row.size != @data.first.size # does not apply if columns of the row get mapped

      original_data  = Array.new(width)
      coerced_values = Array.new(width)
      row_errors     = []
      coerced_row    = CoercedRow.new(self, index, coerced_values, column_errors, row_errors)

      if index > 0 || !@has_headers
        raw_row.values_at(*source_indices).zip(sourced_columns) do |value, column|
          original_data[column.target_index]  = value
          coerced_value, errors               = column.coerce(value)
          coerced_values[column.target_index] = coerced_value
          column_errors[column.accessor] = errors unless errors.empty?
        end
        calculated_columns.each do |column|
          coerced_values[column.target_index] = column.calculate(coerced_row)
        end
      else
        raw_row.values_at(*source_indices).zip(sourced_columns) do |value, column|
          original_data[column.target_index]  = value
          coerced_values[column.target_index] = value
        end
        calculated_columns.each do |column|
          coerced_values[column.target_index] = column.header
        end
      end

      @original_data << original_data
      @original_rows << Row.new(self, index, original_data)
      @data << coerced_values
      @rows << coerced_row

      self
    end

    def valid?
      @table_errors.empty? && @rows.all?(&:valid?)
    end
  end
end
