# encoding: utf-8

require 'table_data/presenter'
TableData.require_library 'prawn', "To generate PDF files, the gem 'prawn' must be installed."


module TableData
  module Presenters
    class PDF < TableData::Presenter

      def document
        pdf = Prawn::Document.new
        tables.each do |id, table|
          pdf.table table.data
        end

        pdf
      end

      def string(options=nil)
        document.render
      end

      def write(path, options=nil)
        document.render_file(path)
      end
    end
  end
end
