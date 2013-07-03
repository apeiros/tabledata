# encoding: utf-8

require 'tabledata/parser'
require 'tabledata/row'
require 'tabledata/column'
require 'tabledata/detection'
require 'tabledata/exceptions'
require 'tabledata/presenter'

module TableData

  # This class represents the tabular data.
  class Table

    include Enumerable

    # The default options for TableData::Table#initialize
    DefaultOptions = {
      has_header: true,
      has_footer: false, # currently unused
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

    # @return [Array<Symbol>] An array of all named accessors
    attr_reader :accessors

    # @return [Hash<Symbol => Integer>] A hash mapping column accessor names to the column index
    attr_reader :accessor_columns

    # @private
    # The internal data structure. Do not modify.
    attr_reader :data

    def initialize(data=[], options=nil)
      options           = options ? self.class::DefaultOptions.merge(options) : self.class::DefaultOptions.dup
      column_count      = data.first ? data.first.size : 0
      @has_header       = options.delete(:has_header) ? true : false
      @data             = data
      @rows             = data.map.with_index { |row, index|
        raise InvalidColumnCount, "Invalid column count in row #{index} (#{column_count} expected, but has #{row.size})" if index > 0 && row.size != column_count
        raise ArgumentError, "Row must be provided as Array, but got #{row.class} in row #{index}" unless row.is_a?(Array)

        Row.new(self, index, row)
      }
      @column_count     = nil
      @header_columns   = nil
      @accessor_columns = {}
      @column_accessors  = {}
      @accessors        = [].freeze
      self.accessors    = options.delete(:accessors)
    end

    # @param [Array<Symbol>] accessors
    #
    # Define the name of the accessors used in TableData::Row.
    def accessors=(accessors)
      if accessors
        @accessors = accessors.map(&:to_sym).freeze
        @accessors.each_with_index do |name, idx|
          @accessor_columns[name] = idx
        end
        @column_accessors  = @accessor_columns.invert
      else
        @accessors = [].freeze
        @accessor_columns.clear
        @column_accessors  = @accessor_columns.clear
      end
    end

    # The number of rows, excluding headers
    def size
      @data.size - (@has_header ? 1 : 0)
    end
    alias length size

    # @return [Integer] The number of columns
    def column_count
      @data.first ? @data.first.size : 0
    end

    # Array#[] like access to the rows in the body of the table.
    #
    # @return [Array<TableData::Row>]
    def [](*args)
      body[*args]
    end

    def cell(row, column, default=nil)
      row_data = row(row)

      if row_data
        row_data.at(column)
      elsif block_given?
        yield(self, row, column)
      else
        default
      end
    end

    def row(row)
      @rows[row]
    end

    def column_accessor(index)
      @column_accessors[index]
    end

    def column_name(index)
      h = headers

      h && h.at(index)
    end

    def columns
      Array.new(column_count) { |col| column(col) }
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
      !@accessors.empty?
    end

    def headers?
      @has_header
    end

    def headers
      headers? ? @rows.first : nil
    end

    def body
      headers? ? @rows[1..-1] : @rows
    end

    def <<(row)
      index  = @data.size

      raise InvalidColumnCount, "Invalid column count in row #{index} (#{@data.first.size} expected, but has #{row.size})" if @data.first && row.size != @data.first.size
      raise ArgumentError, "Row must be provided as Array, but got #{row.class} in row #{index}" unless row.is_a?(Array)

      @data << row
      @rows << Row.new(self, index, row)

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
      return enum_for(__method__) unless block

      body.each(&block)

      self
    end

    # Iterate over all rows, header and body
    #
    # @see TableData::Table#each A method which iterates only over body-rows
    #
    # @yield [row]
    # @yieldparam [TableData::Row]
    #
    # @return [self]
    def each_row(&block)
      return enum_for(__method__) unless block

      @data.each(&block)

      self
    end

    # Iterate over all columns
    #
    # @yield [column]
    # @yieldparam [TableData::Column]
    #
    # @return [self]
    def each_column
      return enum_for(__method__) unless block

      column_count.times do |i|
        yield column(i)
      end

      self
    end

    def to_nested_array
      to_a.map(&:to_a)
    end

    def to_a
      @data
    end

    def format(format_id, options=nil)
      Presenter.present(self, format_id, options)
    end

    def inspect
      sprintf "#<%s headers: %p, cols: %d, rows: %d>", self.class, headers?, column_count, size
    end
  end
end
