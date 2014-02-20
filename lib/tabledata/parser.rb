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
      table       = table_class.new(options)
      data        = read_file(file, options && options[:encoding])
      seperator   = (options && options[:separator]) || Detection.guess_csv_delimiter(data)
      CSV.parse(data,col_sep: seperator) do |row|
        table << row
      end

      table
    end

    def table_from_xls(file, options=nil)
      TableData.require_library 'roo', "To parse Excel .xls files, the gem 'roo' must be installed." # TODO: get rid of that dependency
      #TableData.require_library 'iconv', "To parse Excel .xls files, the gem 'iconv' must be installed." # TODO: get rid of that dependency

      document = Roo::Excel.new(file)
      sheet    = options[:sheet] ? document.sheet(options[:sheet]) : document.default_sheet
      excel_sheet_to_table(sheet, options)
    end

    def table_from_xlsx(file, options=nil)
      TableData.require_library 'roo', "To parse Excel .xlsx files, the gem 'roo' must be installed." # TODO: get rid of that dependency

      document = Roo::Excelx.new(file)
      sheet    = options[:sheet] ? document.sheet(options[:sheet]) : document.default_sheet
      excel_sheet_to_table(sheet, options)
    end

    def tables_from_xls(file, options=nil)
      TableData.require_library 'roo', "To parse Excel .xls files, the gem 'roo' must be installed." # TODO: get rid of that dependency
      #TableData.require_library 'iconv', "To parse Excel .xls files, the gem 'iconv' must be installed." # TODO: get rid of that dependency

      document = Roo::Excel.new(file)
      tables   = Hash[document.sheets.map { |sheet_name| [sheet_name, excel_sheet_to_table(document.sheet(sheet_name), options)] }]

      Tables.new(tables)
    end

    def tables_from_xlsx(file, options=nil)
      TableData.require_library 'roo', "To parse Excel .xlsx files, the gem 'roo' must be installed." # TODO: get rid of that dependency

      document = Roo::Excelx.new(file)
      tables   = Hash[document.sheets.map { |sheet_name| [sheet_name, excel_sheet_to_table(document.sheet(sheet_name), options)] }]

      Tables.new(tables)
    end

    def excel_sheet_to_table(excel, options)
      table_class = (options && options[:table_class]) || Table
      table       = table_class.new(options)
      excel.first_row.upto(excel.last_row) do |row|
        table << excel.row(row)
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
