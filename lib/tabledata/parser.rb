# encoding: utf-8

require 'tabledata/detection'
require 'tabledata/table'
require 'stringio'

module Tabledata
  module Parser
  module_function

    # @private
    # Parse a CSV to a Table
    # Private because API might change.
    def parse_csv(file, options=nil)
      Tabledata.require_library 'csv', "To parse CSV files, the gem 'csv' must be installed." # Should not really happen, in 1.9, csv is part of stdlib and should be present

      table_class = (options && options[:table_class]) || Table
      table       = table_class.new(options)
      data        = read_file(file, options && options[:encoding])
      seperator   = (options && options[:separator]) || Detection.guess_csv_delimiter(data)
      CSV.parse(data,col_sep: seperator) do |row|
        table << row
      end

      table
    end

    # @private
    # Parse an Excel .xls to a Table (default sheet, or the sheet passed)
    # Private because API might change.
    def table_from_xls(file, options=nil)
      Tabledata.require_library 'roo', "To parse Excel .xls files, the gem 'roo' must be installed." # TODO: get rid of that dependency
      #Tabledata.require_library 'iconv', "To parse Excel .xls files, the gem 'iconv' must be installed." # TODO: get rid of that dependency

      options    = options.dup
      document   = Roo::Excel.new(file)
      sheet_name = options.delete(:sheet) || document.default_sheet
      excel_sheet_to_table(document.sheet(sheet_name), sheet_name, options)
    end

    # @private
    # Parse an Excel .xlsx to a Table (default sheet, or the sheet passed)
    # Private because API might change.
    def table_from_xlsx(file, options=nil)
      Tabledata.require_library 'roo', "To parse Excel .xlsx files, the gem 'roo' must be installed." # TODO: get rid of that dependency

      options    = options.dup
      document   = Roo::Excelx.new(file)
      sheet_name = options.delete(:sheet) || document.default_sheet
      excel_sheet_to_table(document.sheet(sheet_name), sheet_name, options)
    end

    # @private
    # Parse an Excel .xls to Tables (all sheets)
    # Private because API might change.
    def tables_from_xls(file, options=nil)
      Tabledata.require_library 'roo', "To parse Excel .xls files, the gem 'roo' must be installed." # TODO: get rid of that dependency
      #Tabledata.require_library 'iconv', "To parse Excel .xls files, the gem 'iconv' must be installed." # TODO: get rid of that dependency

      document = Roo::Excel.new(file)
      tables   = Hash[document.sheets.map { |sheet_name| [sheet_name, excel_sheet_to_table(document.sheet(sheet_name), sheet_name, options)] }]

      Tables.new(tables)
    end

    # @private
    # Parse an Excel .xlsx to Tables (all sheets)
    # Private because API might change.
    def tables_from_xlsx(file, options=nil)
      Tabledata.require_library 'roo', "To parse Excel .xlsx files, the gem 'roo' must be installed." # TODO: get rid of that dependency

      document = Roo::Excelx.new(file)
      tables   = Hash[document.sheets.map { |sheet_name| [sheet_name, excel_sheet_to_table(document.sheet(sheet_name), sheet_name, options)] }]

      Tables.new(tables)
    end

    # @private
    # Convert a sheet from a Roo::Excel or Roo::ExcelX to a Table
    # Private because API might change.
    def excel_sheet_to_table(excel, sheet_name, options)
      table_class = table_class_for_sheet(sheet_name, options)
      table       = table_class.new(options)
      excel.first_row.upto(excel.last_row) do |row|
        table << excel.row(row)
      end

      table
    end

    def table_class_for_sheet(sheet_name, options)
      if options
        if options[:table_classes]
          options[:table_classes][sheet_name] || options[:table_class] || Table
        else
          options[:table_class] || Table
        end
      else
        Table
      end
    end

    # @private
    # Read a file in the correct encoding
    # Private because API might change.
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
