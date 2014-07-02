# encoding: utf-8

require 'tabledata/presenter'
require 'csv'

module Tabledata
  module Presenters
    class CSV < Tabledata::Presenter
      OptionMapping = {
        column_separator: :col_sep,
        row_separator:    :row_sep,
        quote_char:       :quote_character,
      }

      def csv_options
        options = ::CSV::DEFAULT_OPTIONS.dup
        @options.each do |k,v| options[OptionMapping.fetch(k,k)] = v end

        options
      end

      def string(options=nil)
        ::CSV.generate(csv_options) do |csv|
          @table.each_row do |row|
            csv << row.present(:csv)
          end
        end
      end

      def write(path, options=nil)
        ::CSV.open(path, 'wb', csv_options) do |csv|
          @table.each_row do |row|
            csv << row.present(:csv)
          end
        end
      end
    end
  end
end
