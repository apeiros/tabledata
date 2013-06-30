# encoding: utf-8

module TableData
  class Presenter
    @presenters = {
      csv:       ['tabledata/presenters/csv',   [:TableData, :Presenters, :CSV],   {}],
      excel_csv: ['tabledata/presenters/csv',   [:TableData, :Presenters, :CSV],   {column_separator: ";", row_separator: "\r\n"}],
      tab:       ['tabledata/presenters/csv',   [:TableData, :Presenters, :CSV],   {column_separator: "\t"}],
      xls:       ['tabledata/presenters/excel', [:TableData, :Presenters, :Excel], {suffix: '.xls'}],
      xlsx:      ['tabledata/presenters/excel', [:TableData, :Presenters, :Excel], {suffix: '.xlsx'}],
      html:      ['tabledata/presenters/html',  [:TableData, :Presenters, :HTML],  {}],
      pdf:       ['tabledata/presenters/pdf',   [:TableData, :Presenters, :PDF],   {}],
    }

    def self.present(table, format, options)
      code, constant, default_options = *@presenters[format]
      raise ArgumentError, "Unknown format #{format.inspect}" unless code
      require code
      klass = constant.inject(Object) { |source, current| source.const_get(current) }

      klass.new(table, options ? default_options.merge(options) : default_options.dup)
    end

    attr_reader :table

    def initialize(table, options)
      @table   = table
      @options = options
    end

    def write(path, options=nil)
      File.write(path, string, encoding: 'utf-8')
    end
  end
end
