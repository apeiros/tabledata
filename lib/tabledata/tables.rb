# encoding: utf-8

require 'tabledata/table'

module Tabledata

  # This class represents a list of named tables.
  class Tables
    include Enumerable

    def self.from_data(data, common_options=nil)
      common_options ||= {}
      tables           = Hash[data.map { |k,v|
        [k, v.is_a?(Table) ? v : Table.new(common_options.merge(name: name, data: v))]
      }]

      new(tables)
    end

    def self.from_file(path, options=nil)
      options = options ? options.dup : {}
      options[:table_class] ||= Tabledata::Table
      options[:file_type]   ||= Detection.file_type_from_path(path)
      options[:name]        ||= File.basename(path).sub(/\.(?:csv|xlsx?)\z/, '')
      if options[:table_classes].is_a?(Array)
        options[:table_classes] = Hash[options[:table_classes].map { |table_class| [table_class.table_name, table_class] }]
      end

      case options[:file_type]
        when :csv then Parser.parse_csv(path, options)
        when :xls then Parser.tables_from_xls(path, options)
        when :xlsx then Parser.tables_from_xlsx(path, options)
        else raise InvalidFileType, "Unknown file format #{options[:file_type].inspect}"
      end
    end

    def initialize(tables)
      @tables = tables
    end

    def each(&block)
      @tables.each(&block)
    end

    def each_table(&block)
      @tables.each_value(&block)
    end

    def [](key)
      @tables[key]
    end

    def []=(key, table)
      @tables[key] = table
    end

    def to_data
      Hash[@tables.map { |name, table| [name, table.to_nested_array] }]
    end

    def to_hash
      @tables.dup
    end
    alias to_h to_hash

    def format(format_id, options=nil)
      Presenter.present(self, format_id, options)
    end

    def inspect
      sprintf "#<%s %s>", self.class, @tables.inspect[1..-2]
    end
  end
end
