# encoding: utf-8

module Tabledata
  module Processors
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
  end
end
