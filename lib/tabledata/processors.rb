# encoding: utf-8

require 'tabledata/processors/string_processor'
require 'tabledata/processors/integer_processor'
require 'tabledata/processors/float_processor'
require 'tabledata/processors/date_processor'
require 'tabledata/processors/datetime_processor'
require 'tabledata/processors/boolean_processor'
require 'tabledata/processors/binary_processor'

module Tabledata
  module Processors
    @processors = {
      string:   StringProcessor,
      integer:  IntegerProcessor,
      float:    FloatProcessor,
      datetime: DateTimeProcessor,
      date:     DateProcessor,
      boolean:  BooleanProcessor,
      binary:   BinaryProcessor,
    }

    def self.fetch(*args, &block)
      @processors.fetch(*args, &block)
    end

    def self.[](*key)
      @processors[*key]
    end
  end
end
