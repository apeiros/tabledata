# encoding: utf-8

require 'tabledata/column_definition'
require 'tabledata/table_definition'
require 'tabledata/custom_table'

module Tabledata
  module Dsls
    class TableDefinition
      attr_reader :identifier
      attr_reader :columns

      def initialize(identifier=nil, table_name=nil, &block)
        @identifier       = identifier
        @table_name       = table_name
        @column_defaults  = {}
        @current_index    = -1
        @occupied_indices = {}
        @columns          = []
        instance_eval(&block)

        @columns.sort_by!(&:index)
      end

      def definition
        Tabledata::TableDefinition.new(@identifier, @table_name, @columns)
      end

      def column_defaults(value)
        @column_defaults = value
      end

      def define_column(type, accessor, *args)
        header              = args.shift if args.first.is_a?(String)
        options             = args.last.is_a?(Hash) ? @column_defaults.merge(args.pop.dup) : @column_defaults.dup
        default             = options.delete(:default) { nil }
        allow_nil           = options.delete(:nil) { true }
        adaptor             = options.delete(:adapt)
        validator           = options.delete(:validate)
        pre_validator       = options.delete(:pre_validate)
        empty_string_is_nil = options.delete(:empty_string_is_nil) { false }
        strip               = options.delete(:strip) { false }
        index               = options.delete(:index) { next_index }
        column              = ColumnDefinition.new(index, accessor, header, type, allow_nil, default, strip, empty_string_is_nil, pre_validator, adaptor, validator, options)

        @occupied_indices[index] = true
        @columns << column

        column
      end

      def skip_columns(n=1)
        @current_index += n
      end

      def next_index
        begin
          @current_index += 1
        end while @occupied_indices[@current_index]

        @current_index
      end

      def string(*args)
        define_column :string, *args
      end

      def integer(*args)
        define_column :integer, *args
      end

      def date(*args)
        define_column :date, *args
      end

      def datetime(*args)
        define_column :datetime, *args
      end

      def boolean(*args)
        define_column :boolean, *args
      end

      def binary(*args)
        define_column :binary, *args
      end

      def validate_row
      end

      def validate_table
      end
    end
  end
end
