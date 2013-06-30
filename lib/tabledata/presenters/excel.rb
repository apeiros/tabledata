# encoding: utf-8

require 'tabledata/presenter'
TableData.require_library 'spreadsheet', "To generate Excel files, the gem 'spreadsheet' must be installed."
require 'tabledata/patches/spreadsheet'


module TableData
  module Presenters
    class Excel < TableData::Presenter
      Bold = Spreadsheet::Format.new weight: :bold

      def document
        document          = Spreadsheet::Workbook.new
        sheet             = document.create_worksheet(name: @options[:worksheet_name])
        sheet.row(0).default_format = Bold if @options[:bold_headers]

        @table.data.each_with_index do |row, row_nr|
          row.each_with_index do |col, col_nr|
            sheet[row_nr, col_nr] = col
          end
        end

        document
      end

      def string(options=nil)
        document.to_string
      end

      def write(path, options=nil)
        document.write(path)
      end
    end
  end
end
