# encoding: utf-8

module TableData

  # All exceptions raised by TableData include TableData::Exception,
  # so you can rescue all of them using `rescue TableData::Exception`.
  module Exception
  end

  class InvalidOptions < ArgumentError
    include TableData::Exception

    def self.verify!(method_name, options, valid_keys)
      invalid_keys = options.keys-valid_keys
      raise new(method_name, invalid_keys) unless invalid_keys.empty?
    end

    def initialize(method_name, invalid_keys)
      super("Invalid options for method #{method_name}: #{invalid_keys.inspect[1..-2]}")
    end
  end
  class InvalidFileType < ArgumentError
    include TableData::Exception
  end
  class InvalidColumnCount < ArgumentError
    include TableData::Exception

    def initialize(row_num, expected, actual)
      super("Invalid column count in row #{row_num} (#{expected} expected, but has #{actual})")
    end
  end
  class InvalidColumnSpecifier < ArgumentError; include TableData::Exception; end
  class InvalidColumnName < InvalidColumnSpecifier; end
  class InvalidColumnAccessor < InvalidColumnSpecifier; end
  class LibraryMissingError < LoadError
    include TableData::Exception

    attr_reader :name, :cause

    def initialize(name, message, error)
      @name  = name
      @cause = error

      super(message)
    end
  end
end
