# encoding: utf-8

module Tabledata
  module Processors
    class BinaryProcessor
      def initialize(options)
      end
      def call(value, errors)
        value.dup.force_encoding(Encoding::BINARY)
      end
    end
  end
end
