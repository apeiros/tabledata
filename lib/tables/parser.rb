# encoding: utf-8

require 'tables/detection'
require 'tables/table'
require 'stringio'

module Tables
  module Parser
  module_function

    class LibraryMissingError < LoadError
      def initialize(name, message, error)
        super(
          "#{message}\n" \
          "On most systems, you can install the library using `gem install '#{name}'`\n" \
          "Original error: #{error.message}"
        )
        set_backtrace error.backtrace
      end
    end

    def require_library(name, message)
      $stdout, oldstdout = StringIO.new, $stdout
      require name
    rescue LoadError => error
      if error.message =~ /cannot load such file -- #{Regexp.escape(name)}/ then
        raise LibraryMissingError.new(name, message, error)
      else
        raise
      end
    ensure
      $stdout = oldstdout
    end

    def parse_csv(file, options=nil)
      require_library 'csv', "To parse CSV files, the gem 'csv' must be installed." # Should not really happen, in 1.9, csv is part of stdlib and should be present

      table_class = (options && options[:table_class]) || Table
      table       = table_class.new(options)
      data        = read_file(file, options && options[:encoding])
      seperator   = (options && options[:separator]) || Detection.guess_csv_delimiter(data)
      CSV.parse(data,col_sep: seperator) do |row|
        table << row
      end

      table
    end

    def parse_xls(file, options=nil)
      require_library 'roo', "To parse Excel .xls files, the gem 'roo' must be installed." # TODO: get rid of that dependency
      require_library 'iconv', "To parse Excel .xls files, the gem 'iconv' must be installed." # TODO: get rid of that dependency

      table_class = (options && options[:table_class]) || Table
      table       = table_class.new(options)
      parser      = Excel.new(file)
      parser.first_row.upto(parser.last_row) do |row|
        table << parser.row(row)
      end

      table
    end

    def parse_xlsx(file, options=nil)
      require_library 'roo', "To parse Excel .xlsx files, the gem 'roo' must be installed." # TODO: get rid of that dependency

      table_class = (options && options[:table_class]) || Table
      table       = table_class.new(options)
      parser      = Excelx.new(file)
      parser.first_row.upto(parser.last_row) do |row|
        table << parser.row(row)
      end

      table
    end

    def read_file(path, encoding)
      if encoding then
        File.read(path, encoding: encoding)
      else
        data = File.read(path, encoding: Encoding::BINARY)
        Detection.force_guessed_encoding!(data)
        data.encode!(Encoding.default_internal) if Encoding.default_internal

        data
      end
    end
  end
end
