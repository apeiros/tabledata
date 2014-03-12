# encoding: utf-8

require 'table_data/parser'
require 'table_data/row'
require 'table_data/column'
require 'table_data/detection'
require 'table_data/exceptions'
require 'table_data/presenter'

module TableData

  # Table represents tabular data and provides various ways to create one,
  # read from it and represent it in a different format.
  class TableDefinition
    attr_reader :identifier
    attr_reader :columns

    def initialize(identifier, columns)
      @identifier = identifier
      @columns    = columns
    end

    def create_table_class
      table_definition = self

      Class.new(TableData::CustomTable) do
        @definition = table_definition
      end
    end
  end
end
