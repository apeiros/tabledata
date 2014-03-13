# encoding: utf-8

module Tabledata
  module Processors
    class FloatProcessor
      def initialize(options)
        options     = options.dup
        value_range = options.delete(:between)
        @min        = options.delete(:min) || (value_range && value_range.begin) || 0
        @max        = options.delete(:max) || (value_range && value_range.end) || 0
        @round      = options.delete(:round)
      end
    end
  end
end
