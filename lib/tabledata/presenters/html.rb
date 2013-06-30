# encoding: utf-8

require 'tabledata/presenter'
require 'cgi'

module TableData
  module Presenters
    class HTML < TableData::Presenter
      def html_head
        <<-EOHTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset='utf-8'>
  </head>
  <body>
    <table>
        EOHTML
      end

      def html_foot
        <<-EOHTML

      </tbody>
    </table>
  </body>
</html>
        EOHTML
      end

      def html_table_header
        if @table.headers?
          "      <thead>\n        <tr>\n"+
            @table.headers.map { |cell|"          <th>#{CGI.escapeHTML(cell)}</th>" }.join("\n")+
            "\n        </tr>\n      </thead>\n"
        else
          ''
        end
      end

      def string(options=nil)
        html_head+
          html_table_header+
          "      </body>\n"+
          @table.body.map { |row|
            "        <tr>\n"+row.map { |cell| "          <td>#{CGI.escapeHTML(cell)}</td>" }.join("\n")+"\n        </tr>"
          }.join("\n")+
          html_foot
      end

      def write(path, options=nil)
        File.write(path, string, encoding: 'utf-8')
      end
    end
  end
end
