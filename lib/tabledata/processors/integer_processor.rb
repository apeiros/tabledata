# encoding: utf-8

module Tabledata
  module Processors
    class IntegerProcessor
      def initialize(options)
        options     = options.dup
        value_range = options.delete(:between)
        @min        = options.delete(:min) || (value_range && value_range.begin) || false
        @max        = options.delete(:max) || (value_range && value_range.end) || false
      end

      def call(value, errors)
        case value
          when /\A\s*\z/
            processed = nil
          when String
            begin
              processed = Integer(value, 10)
            rescue ArgumentError
              processed = nil
              errors << [:not_an_integer, {value: value}]
            end
          when Integer
            processed = value
          when Numeric
            processed = value.round
            difference = value-processed
            errors << [:not_an_integral_number, {rounded: processed, unrounded: value, difference: difference, absolute_difference: difference.abs}] if difference.abs > Float::EPSILON
          else
            begin
              processed = Integer(value)
            rescue ArgumentError
              errors << [:invalid_input, {value: value}]
            end
        end

        if processed
          errors << [:too_small, { min: @min, actual: processed }] if @min && processed < @min
          errors << [:too_big,   { max: @max, actual: processed }] if @max && processed > @max
        end

        processed
      end
    end
  end
end
