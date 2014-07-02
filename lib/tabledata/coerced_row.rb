# encoding: utf-8

require 'tabledata/row'

module Tabledata
  class CoercedRow < Row

    attr_reader :column_errors
    attr_reader :row_errors

    def initialize(table, index, data, column_errors={}, row_errors=[])
      super(table, index, data)
      @column_errors = column_errors
      @row_errors    = row_errors
    end

    def present(media)
      @data.zip(@table.class.definition.columns).map { |value, column| column.present(value, media) }
    end

    # Allow reading and writing cell values by their accessor name.
    def method_missing(name, *args, &block)
      return super unless @table.accessors?

      name              =~ /^(\w+)(=)?$/
      name_mod, assign  = $1, $2
      index             = @table.index_for_accessor(name_mod)
      arg_count         = assign ? 1 : 0

      return super unless index

      raise ArgumentError, "Wrong number of arguments (#{args.size} for #{arg_count})" if args.size > arg_count

      if assign then
        raise "Coercions not yet implemented" # todo, coerce data when set
        @data[index] = args.first
      else
        @data[index]
      end
    end

    def valid?
      @column_errors.empty? && @row_errors.empty?
    end
  end
end
