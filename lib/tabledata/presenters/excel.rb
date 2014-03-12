# encoding: utf-8

require 'tabledata/presenter'
Tabledata.require_library 'spreadsheet', "To generate Excel files, the gem 'spreadsheet' must be installed."
require 'tabledata/patches/spreadsheet'


module Tabledata
  module Presenters
    class Excel < Tabledata::Presenter
      Bold = Spreadsheet::Format.new weight: :bold

      def document
        document = Spreadsheet::Workbook.new

        tables.each do |id, table|
          sheet = document.create_worksheet(name: worksheet_name(id))
          sheet.row(0).default_format = Bold if @options[:bold_headers]

          table.data.each_with_index do |row, row_nr|
            row.each_with_index do |col, col_nr|
              sheet[row_nr, col_nr] = col
            end
          end
        end

        document
      end

      def worksheet_name(id)
        single_table? || id.nil? ? @options[:worksheet_name] : @options.fetch(:worksheet_names, {}).fetch(id, id.to_s)
      end

      def string(options=nil)
        document.to_string
      end

      def write(path, options=nil)
        document.write(path)

        path
      end
    end
  end
end
