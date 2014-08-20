# encoding: utf-8

require 'tabledata/parser'
require 'tabledata/row'
require 'tabledata/column'
require 'tabledata/detection'
require 'tabledata/exceptions'
require 'tabledata/presenter'

module Tabledata

  # Table represents tabular data and provides various ways to create one,
  # read from it and represent it in a different format.
  class TableDefinition
    attr_reader :identifier
    attr_reader :table_name
    attr_reader :columns

    def initialize(identifier, table_name, columns)
      @identifier = identifier
      @table_name = table_name || identifier.to_s
      @columns    = columns
      @columns_by_accessor = Hash[columns.map { |column| [column.accessor, column] }]
    end

    def column(index_or_accessor)
      case index_or_accessor
        when Integer
          @columns[index_or_accessor]
        when Symbol
          @columns_by_accessor[index_or_accessor]
        else
          raise TypeError, "Expected Integer (index) or Symbol (accessor), but got #{index_or_accessor.class}:#{index_or_accessor.inspect}"
      end
    end

    def source_indices
      @columns.map(&:source_index).compact
    end

    def target_indices
      @columns.map(&:target_index).compact
    end

    def sourced_columns
      @columns.select(&:source_index)
    end

    def calculated_columns
      @columns.select(&:calculated?)
    end

    def accessors
      @columns.map(&:accessors)
    end

    def create_table_class
      table_definition = self

      Class.new(Tabledata::CustomTable) do
        @definition = table_definition
      end
    end
  end
end
