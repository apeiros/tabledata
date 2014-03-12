# encoding: utf-8

require 'tabledata/presenter'
require 'cgi'

module Tabledata
  module Presenters
    class HTML < Tabledata::Presenter
      def html_head
        <<-EOHTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset='utf-8'>
  </head>
  <body>
        EOHTML
      end

      def html_foot
        <<-EOHTML
  </body>
</html>
        EOHTML
      end

      def html_table_header
        if @table.headers?
          "    <table>\n" +
          "      <thead>\n        <tr>\n"+
            @table.headers.map { |cell|"          <th>#{CGI.escapeHTML(cell)}</th>" }.join("\n")+
            "\n        </tr>\n      </thead>\n"
        else
          "    <table>\n"
        end
      end

      def tables_html
        html_head+tables.map { |table| table_html(table) }.join('')+html_foot
      end

      def table_html(table)
        html_table_header+
          "      <tbody>\n"+
          table.body.map { |row|
            "        <tr>\n"+row.map { |cell| "          <td>#{CGI.escapeHTML(cell)}</td>" }.join("\n")+"\n        </tr>\n"
          }.join("")+
          "      </tbody>\n"+
          "    </table>\n"
      end

      def string(options=nil)
        table_html
      end
    end
  end
end
