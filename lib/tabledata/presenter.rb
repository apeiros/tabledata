# encoding: utf-8

module TableData
  class Presenter
    @presenters = {
      # format:  [require, constant, multitable_capable, default_options]
      csv:       ['tabledata/presenters/csv',   [:TableData, :Presenters, :CSV],   false, {}],
      excel_csv: ['tabledata/presenters/csv',   [:TableData, :Presenters, :CSV],   false, {column_separator: ";", row_separator: "\r\n"}],
      tab:       ['tabledata/presenters/csv',   [:TableData, :Presenters, :CSV],   false, {column_separator: "\t"}],
      xls:       ['tabledata/presenters/excel', [:TableData, :Presenters, :Excel], true,  {suffix: '.xls'}],
      xlsx:      ['tabledata/presenters/excel', [:TableData, :Presenters, :Excel], true,  {suffix: '.xlsx'}],
      excel:     ['tabledata/presenters/excel', [:TableData, :Presenters, :Excel], true,  {suffix: '.xlsx'}],
      html:      ['tabledata/presenters/html',  [:TableData, :Presenters, :HTML],  false, {}],
      pdf:       ['tabledata/presenters/pdf',   [:TableData, :Presenters, :PDF],   false, {}],
    }

    def self.presenter_exists?(name)
      @presenters.has_key?(name)
    end

    def self.add_presenter!(name, *args)
      raise "Presenter #{name.inspect} already exists" if presenter_exists?(name)
      @presenters[name] = args
    end

    def self.replace_presenter!(name, *args)
      raise "Presenter #{name.inspect} does not exist" unless presenter_exists?(name)
      @presenters[name] = args
    end

    def self.present(table, format, options)
      code, constant, multitable_capable, default_options = *@presenters[format]
      raise ArgumentError, "Unknown format #{format.inspect}" unless code
      require code
      klass = constant.inject(Object) { |source, current| source.const_get(current) }

      klass.new(table, multitable_capable, options ? default_options.merge(options) : default_options.dup)
    end

    attr_reader :table, :tables, :options

    def initialize(table, multiple_capable, options)
      if table.is_a?(Tables)
        @tables = table
        @table  = nil
      else
        @tables = Tables.new(nil => table)
        @table  = table
      end
      raise "Not capable to process multiple tables" if multiple_tables? && !multiple_capable
      @options = options
    end

    def single_table?
      @table ? true : false
    end

    def multiple_tables?
      @table ? false : true
    end

    def write(path, options=nil)
      File.write(path, string(options), encoding: 'utf-8')
    end
  end
end
