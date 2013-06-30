# encoding: utf-8

require 'tabledata/detection'
require 'tabledata/table'
require 'stringio'

module TableData
  module Parser
  module_function

    def parse_csv(file, options=nil)
      TableData.require_library 'csv', "To parse CSV files, the gem 'csv' must be installed." # Should not really happen, in 1.9, csv is part of stdlib and should be present

      table_class = (options && options[:table_class]) || Table
      table       = table_class.new([], options)
      data        = read_file(file, options && options[:encoding])
      seperator   = (options && options[:separator]) || Detection.guess_csv_delimiter(data)
      CSV.parse(data,col_sep: seperator) do |row|
        table << row
      end

      table
    end

    def parse_xls(file, options=nil)
      TableData.require_library 'roo', "To parse Excel .xls files, the gem 'roo' must be installed." # TODO: get rid of that dependency
      TableData.require_library 'iconv', "To parse Excel .xls files, the gem 'iconv' must be installed." # TODO: get rid of that dependency

      table_class = (options && options[:table_class]) || Table
      table       = table_class.new([], options)
      parser      = Roo::Excel.new(file)
      parser.first_row.upto(parser.last_row) do |row|
        table << parser.row(row)
      end

      table
    end

    def parse_xlsx(file, options=nil)
      TableData.require_library 'roo', "To parse Excel .xlsx files, the gem 'roo' must be installed." # TODO: get rid of that dependency

      table_class = (options && options[:table_class]) || Table
      table       = table_class.new([], options)
      parser      = Roo::Excelx.new(file)
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
