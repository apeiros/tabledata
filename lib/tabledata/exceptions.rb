# encoding: utf-8

module TableData

  # All exceptions raised by TableData include TableData::Exception,
  # so you can rescue all of them using `rescue TableData::Exception`.
  module Exception
  end

  class InvalidFileType < ArgumentError
    include Exception
  end
  class InvalidColumnCount < ArgumentError
    include Exception
  end
  class InvalidColumnSpecifier < ArgumentError
    include Exception

    def initialize(row_num, expected, actual)
      super("Invalid column count in row #{row_num} (#{expected} expected, but has #{actual})")
    end
  end
  class InvalidColumnName < InvalidColumnSpecifier; end
  class InvalidColumnAccessor < InvalidColumnSpecifier; end
  class LibraryMissingError < LoadError
    include Exception

    attr_reader :name, :cause

    def initialize(name, message, error)
      @name  = name
      @cause = error

      super(message)
    end
  end
end
