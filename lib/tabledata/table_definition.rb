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
    end

    def create_table_class
      table_definition = self

      Class.new(Tabledata::CustomTable) do
        @definition = table_definition
      end
    end
  end
end
