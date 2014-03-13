# encoding: utf-8

module Tabledata
  module Processors
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
  end
end
