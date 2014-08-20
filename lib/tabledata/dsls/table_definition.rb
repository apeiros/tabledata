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
        @identifier            = identifier
        @table_name            = table_name
        @column_defaults       = {}
        @current_source_index  = -1
        @current_target_index  = -1
        @previous_source_index = -1
        @previous_target_index = -1
        @sourced_indices       = {}
        @targeted_indices      = {}
        @columns               = []
        instance_eval(&block)

        @columns.sort_by!(&:target_index)
      end

      def definition
        Tabledata::TableDefinition.new(@identifier, @table_name, @columns)
      end

      def column_defaults(value)
        @column_defaults = value
      end

      def define_column(target_type, accessor, *args)
        header              = args.shift if args.first.is_a?(String)
        options             = args.last.is_a?(Hash) ? @column_defaults.merge(args.pop) : @column_defaults.dup
        source_type         = options.delete(:source_type) { target_type }
        default             = options.delete(:default) { nil }
        allow_nil           = options.delete(:nil) { true }
        pre_validator       = options.delete(:pre_validate)
        adaptor             = options.delete(:adapt)
        validator           = options.delete(:validate)
        presenter           = options.delete(:present)
        empty_string_is_nil = options.delete(:empty_string_is_nil) { false }
        strip               = options.delete(:strip) { false }
        source_index        = options.delete(:source_index) { next_source_index }
        target_index        = options.delete(:target_index) { next_target_index }
        calculator          = options.delete(:calculator)
        column              = ColumnDefinition.new(
          source_index,
          target_index,
          accessor,
          header,
          target_type,
          source_type,
          allow_nil,
          default,
          strip,
          empty_string_is_nil,
          pre_validator,
          adaptor,
          validator,
          presenter,
          calculator,
          options
        )

        if source_index
          @sourced_indices[source_index]  = column
          @sourced_indices                = Hash[@sourced_indices.sort] if @previous_source_index > source_index
          @previous_source_index          = source_index
        end
        if target_index
          @targeted_indices[target_index] = column
          @targeted_indices               = Hash[@targeted_indices.sort] if @previous_target_index > target_index
          @previous_target_index          = target_index
        end

        @columns << column

        column
      end

      def skipped?(index)
        !@occupied_indices[index]
      end

      def skip_column
        skip_columns(1)
      end

      def skip(*)
        skip_columns(1)
      end

      def skip_columns(n=1)
        @current_source_index += n
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

      def calculated(accessor, *args, &calculator)
        header = args.shift if args.first.is_a?(String)
        default_options = {
          default:             nil,
          nil:                 nil,
          pre_validate:        nil,
          adapt:               nil,
          validate:            nil,
          present:             nil,
          empty_string_is_nil: nil,
          strip:               nil,
          source_index:        nil,
          calculator:          calculator,
        }
        options = args.last.is_a?(Hash) ? default_options.merge(args.pop) { |key, value1, value2|
          raise ArgumentError, "Must provide either a block, or a :calculator option, not both" if key == :calculator && value1 && value2
          value2 || value1
        } : default_options.dup

        define_column(:calculated, accessor, options)
      end

      def validate_row
      end

      def validate_table
      end

    private
      def next_source_index
        begin
          @current_source_index += 1
        end while @sourced_indices[@current_source_index]

        @current_source_index
      end

      def next_target_index
        begin
          @current_target_index += 1
        end while @targeted_indices[@current_target_index]

        @current_target_index
      end
    end
  end
end
