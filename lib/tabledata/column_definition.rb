# encoding: utf-8

require 'base64'
require 'tabledata/processors'

module Tabledata
  class ColumnDefinition

    # @return [Integer] Index in the file from which you import
    attr_reader :source_index

    # @return [Integer] Index in the tabledata instance.
    attr_reader :target_index

    # @return [Symbol] The name used to access the column in the row, e.g. `:foo` --> `row[:foo]` and row.foo.
    attr_reader :accessor

    # @return [String, nil] The header value of this column.
    attr_reader :header

    # @return [Symbol] The type of the column.
    attr_reader :type

    # @return [Symbol] The type of the column in the file from which it is imported.
    attr_reader :source_type

    # @return [Symbol] Whether nil is a valid value in this column.
    attr_reader :allow_nil

    # @return [Object] The default value of this column. Can be a value which is not valid.
    attr_reader :default

    # @return [true, false] Whether the value is stripped before processing.
    attr_reader :strip

    # @return [true, false] Whether an empty string should be converted to nil.
    attr_reader :empty_string_is_nil

    # @return [Proc, nil] A validator which is run on the raw data, that is before adapting and coercing the value.
    attr_reader :pre_validator

    # @return [Proc, nil] An adaptor, which adapts the stripped, nilled value.
    attr_reader :adaptor

    # @return [Proc, nil] A validator, which validates whether the adapted and processed value is valid.
    attr_reader :validator

    # @return [Proc] A processor, which converts the imported value to the target type.
    attr_reader :processor

    # @return [Proc, nil] For calculated columns, the Proc which calculates the cell value.
    attr_reader :calculator

    # @return [Object] Options passed as-is to the processor. Usually a Hash.
    attr_reader :options

    def initialize(source_index, target_index, accessor, header, type, source_type, allow_nil, default, strip, empty_string_is_nil, pre_validator, adaptor, validator, presenter, calculator, options)
      @source_index        = source_index
      @target_index        = target_index
      @accessor            = accessor
      @header              = header
      @type                = type
      @source_type         = source_type
      @allow_nil           = allow_nil
      @default             = default
      @strip               = strip
      @empty_string_is_nil = empty_string_is_nil
      @pre_validator       = pre_validator
      @adaptor             = adaptor
      @validator           = validator
      @presenter           = presenter.is_a?(Proc) ? Hash.new(presenter) : presenter
      @calculator          = calculator
      @options             = options
      processor            = Tabledata::Processors.fetch(type)
      @processor           = (processor && processor.new(options))
    end

    def calculated?
      @calculator ? true : false
    end

    def present(value, media)
      @presenter ? @presenter[media].call(value) : value
    end

    def calculate(row)
      @calculator.call(self, row)
    end

    # strip, empty-string-to-nil, user-defined pre-validate, type-defined pre-validate, user-defined adaptor, defaultize, type-defined adaptor, user-defined validate
    def coerce(value)
      errors  = []
      adapted = nil

      if @pre_validator.nil? || @pre_validator.call(value)
        begin
          value   = value.strip if @strip && value.is_a?(String)
          value   = nil if @empty_string_is_nil && value.is_a?(String) && value.empty?
          adapted = @adaptor ? @adaptor.call(value) : value
          adapted = @default if adapted.nil?
        rescue => exception
          errors << [:exception, exception]
        else
          adapted = @processor.call(adapted, errors) if @processor && !adapted.nil?
          errors << [:invalid_value] if @validator && !adapted.nil? && !@validator.call(adapted)
          errors << [:invalid_nil_value] if adapted.nil? && !@allow_nil
        end
      else
        errors << [:invalid_input]
      end

      [adapted, errors]
    end
  end
end
