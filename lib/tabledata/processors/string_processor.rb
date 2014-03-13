# encoding: utf-8

module Tabledata
  module Processors
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
  end
end
