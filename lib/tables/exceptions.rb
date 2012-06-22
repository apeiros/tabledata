# encoding: utf-8

module Tables
  module Exception
    class InvalidFileType < ArgumentError
      include Exception
    end
    class InvalidColumnCount < ArgumentError
      include Exception
    end
    class InvalidColumnSpecifier < ArgumentError
      include Exception
    end
    class InvalidColumnName < InvalidColumnSpecifier; end
    class InvalidColumnAccessor < InvalidColumnSpecifier; end
  end
end
