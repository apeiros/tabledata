# encoding: utf-8

require 'tabledata/parser'
require 'tabledata/row'
require 'tabledata/column'
require 'tabledata/detection'
require 'tabledata/exceptions'

module TableData
  class Table
    include Enumerable

    DefaultOptions = {
      has_header: true,
      has_footer: false,
      accessors:  [],
    }

    # @option options [Symbol] :file_type
    #   The file type. Nil for auto-detection (which uses the extension of the
    #   filename), or one of :csv, :xls or :xlsx
    # @option options [Symbol] :table_class
    #   The class to use for this table. Defaults to self (TableData::Table)
    #
    # All other options are passed on to Parser.parse_csv, .parse_xls or parse_xlsx,
    # which in turn passes remaining options on to Table#initialize
    #
    # @return [TableData::Table]
    def self.from_file(path, options=nil)
      options ||= {}
      options[:table_class] ||= self
      options[:file_type]   ||= Detection.file_type_from_path(path)

      case options[:file_type]
        when :csv then Parser.parse_csv(path, options)
        when :xls then Parser.parse_xls(path, options)
        when :xlsx then Parser.parse_xlsx(path, options)
        else raise InvalidFileType, "Unknown file format #{options[:file_type].inspect}"
      end
    end

    attr_reader :accessors

    def initialize(options=nil)
      options           = options ? self.class::DefaultOptions.merge(options) : self.class::DefaultOptions.dup
      @has_header       = options.delete(:has_header) ? true : false
      @data             = []
      @column_count     = nil
      @accessor_columns = {}
      @header_columns   = nil
      accessors         = options.delete(:accessors)
      if accessors.is_a?(Hash)
        @accessors        = Hash[accessors.map { |k,v| [k.to_sym, v] }]
      else
        @accessors        = Hash[accessors.map.with_index { |n, i| [n.to_sym, i] }]
      end

      @accessors.each do |name, idx|
        @accessor_columns[name] = idx
      end
      @column_accssors  = @accessor_columns.invert
    end

    # The number of rows, excluding headers
    def size
      @data.size - (@has_header ? 1 : 0)
    end
    alias length size

    def [](*args)
      body[*args]
    end

    def column_count
      @data.first && @data.first.size
    end

    def column_accessor(index)
      @column_accessors[index]
    end

    def column_name(index)
      h = headers

      h && h.at(index)
    end

    def columns
      return nil unless @data.first

      (0...column_count).map { |col|
        column(col)
      }
    end

    def column(index)
      Column.new(self, index)
    end

    def index_for_accessor(name)
      @accessor_columns[name.to_sym]
    end

    def index_for_header(name)
      if @has_header && @data.first then
        @header_columns ||= Hash[@data.first.each_with_index.to_a]
        @header_columns[name]
      else
        nil
      end
    end

    def accessors?
      !@accessor_columns.empty?
    end

    def headers?
      @has_header
    end

    def headers
      headers? ? @data.first : nil
    end

    def body
      headers? ? @data[1..-1] : @data
    end

    def <<(row)
      @data << Row.new(self, @data.size, row)
      raise InvalidColumnCount, "Invalid column count (#{@data.first.size} expected, but has #{row.size})" unless row.size == @data.first.size

      self
    end

    # Iterate over all rows in the body
    #
    # @see TableData::Table#each_row A method which iterates over all rows, including headers
    #
    # @yield [row]
    # @yieldparam [TableData::Row]
    #
    # @return [self]
    def each(&block)
      body.each(&block)

      self
    end

    def to_nested_array
      to_a.map(&:to_a)
    end

    def to_a
      @data
    end

    def inspect
      sprintf "#<%s headers: %p, cols: %d, rows: %d>", self.class, headers?, column_count, size
    end
  end
end
