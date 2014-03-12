# encoding: utf-8

require 'base64'

module Tabledata
  class ColumnDefinition
    attr_reader :index
    attr_reader :accessor
    attr_reader :header
    attr_reader :type
    attr_reader :allow_nil
    attr_reader :default
    attr_reader :strip
    attr_reader :pre_validator
    attr_reader :adaptor
    attr_reader :validator
    attr_reader :options

    class StringProcessor
      def initialize(options)
        options      = options.dup
        length_range = options.delete(:length)
        length_range = length_range..length_range if length_range.is_a?(Integer)
        @min_length  = options.delete(:min_length) || (length_range && length_range.begin) || nil
        @max_length  = options.delete(:max_length) || (length_range && length_range.end) || nil
        @pattern     = options.delete(:pattern)

        InvalidOptions.verify!(__method__, options, [:size, :min_length, :max_length, :pattern])
      end

      def call(value, errors)
        value = value.to_s unless value.is_a?(String)
        errors << [:too_short, {min_length: @min_length, actual: value.length}] if @min_length && value.length < @min_length
        errors << [:too_long, {max_length: @max_length, actual: value.length}] if @max_length && value.length > @max_length
        errors << [:invalid_format] if @pattern && value !~ @pattern

        value
      end
    end
    class IntegerProcessor
      def initialize(options)
        options     = options.dup
        value_range = options.delete(:between)
        @min        = options.delete(:min) || (value_range && value_range.begin) || 0
        @max        = options.delete(:max) || (value_range && value_range.end) || 0
      end

      def call(value, errors)
        case value
          when /\A\s*\z/
            processed = nil
          when String
            processed = Integer(value, 10)
          when Integer
            processed = value
          when Numeric
            processed = value.round
            difference = value-processed
            errors << [:not_an_integer, {rounded: processed, unrounded: value, difference: difference, absolute_difference: difference.abs}] if difference.abs > Float::EPSILON
          else
            begin
              processed = Integer(value)
            rescue ArgumentError
              errors << [:invalid_input, {value: value}]
            end
        end

        if processed
          errors << [:too_small, {min: @min, actual: processed}] if @min_length && processed < @min_length
          errors << [:too_big, {max: @max, actual: processed}] if @max_length && processed > @max_length
        end

        processed
      end
    end
    class FloatProcessor
      def initialize(options)
        options     = options.dup
        value_range = options.delete(:between)
        @min        = options.delete(:min) || (value_range && value_range.begin) || 0
        @max        = options.delete(:max) || (value_range && value_range.end) || 0
        @round      = options.delete(:round)
      end
    end
    class DateTimeProcessor
      def initialize(options)
      end
      def call(value, errors)
        case value
          when DateTime
            processed = value
          when Time
            processed = DateTime.civil(value.year, value.month, value.day, value.hour, value.min, value.sec+value.usec.fdiv(1000000), value.zone)
          when Date
            processed = DateTime.civil(value.year, value.month, value.day)
          when /\A(\d{4})-(\d\d)-(\d\d)(?:[T ](\d\d)(?::(\d\d)(?::(\d\d))?)?)?\z/
            processed = DateTime.civil($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i)
          when /\A\s*\z/
            processed = nil
          else
            errors << [:invalid_input, {value: value}]
        end

        if processed
          # validate
        end

        processed
      end
    end
    class DateProcessor
      def initialize(options)
      end
      def call(value, errors)
        case value
          when Date
            processed = value
          when Time
            errors << [:not_a_date] unless value.hour == 0 && value.min == 0 && value.sec == 0
            processed = Date.civil(value.year, value.month, value.day)
          when DateTime
            errors << [:not_a_date] unless value.hour == 0 && value.min == 0 && value.sec == 0
            processed = Date.civil(value.year, value.month, value.day)
          when /\A(\d{4})-(\d\d)-(\d\d)[T ](\d\d)(?::(\d\d)(?::(\d\d))?)?\z/
            errors << [:not_a_date] unless $4.to_i == 0 && $5.to_i == 0 && $6.to_i == 0
            processed = Date.civil($1.to_i, $2.to_i, $3.to_i)
          when /\A(\d{4})-(\d\d)-(\d\d)\z/
            processed = Date.civil($1.to_i, $2.to_i, $3.to_i)
          when /\A\s*\z/
            processed = nil
          else
            errors << [:invalid_input, {value: value}]
        end

        if processed
          # validate
        end

        processed
      end
    end
    class BooleanProcessor
      def initialize(options)
        true_values  = options[:true_value].is_a?(Array) ? options.delete(:true_value) : [options.delete(:true_value)]
        false_values = options[:false_value].is_a?(Array) ? options.delete(:false_value) : [options.delete(:false_value)]
        @convert     = {}
        true_values.each do |true_value| @convert[true_value] = true end
        false_values.each do |false_value| @convert[false_value] = false end
        @convert[nil] ||= nil
      end
      def call(value, errors)
        case value
          when TrueClass, FalseClass
            processed = value
          else
            processed = @convert.fetch(value) {
              errors << [:invalid_input, {value: value, acceptable: @convert.values.join(', ')}]
              nil
            }
        end

        processed
      end
    end
    class BinaryProcessor
      def initialize(options)
      end
      def call(value, errors)
        value.dup.force_encoding(Encoding::BINARY)
      end
    end

    Processors = {
      string:   StringProcessor,
      integer:  IntegerProcessor,
      float:    FloatProcessor,
      datetime: DateTimeProcessor,
      date:     DateProcessor,
      boolean:  BooleanProcessor,
      binary:   BinaryProcessor,
    }

    def initialize(index, accessor, header, type, allow_nil, default, strip, empty_string_is_nil, pre_validator, adaptor, validator, options)
      @index               = index
      @accessor            = accessor
      @header              = header
      @type                = type
      @allow_nil           = allow_nil
      @default             = default
      @strip               = strip
      @empty_string_is_nil = empty_string_is_nil
      @pre_validator       = pre_validator
      @adaptor             = adaptor
      @validator           = validator
      @options             = options
      @processor           = Processors.fetch(type).new(options)
    end

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
