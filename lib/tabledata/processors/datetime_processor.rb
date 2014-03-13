# encoding: utf-8

module Tabledata
  module Processors
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
  end
end
