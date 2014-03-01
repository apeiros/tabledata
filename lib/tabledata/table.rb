# encoding: utf-8

require 'tabledata/parser'
require 'tabledata/row'
require 'tabledata/column'
require 'tabledata/detection'
require 'tabledata/exceptions'
require 'tabledata/presenter'

module TableData

  # Table represents tabular data and provides various ways to create one,
  # read from it and represent it in a different format.
  class Table

    include Enumerable

    ValidOptions = [:has_headers, :has_footer, :file_type, :name, :table_class, :accessors, :data, :header, :body, :footer]

    # The default options for TableData::Table#initialize
    # Must be a method because the values should be new objects each time
    def self.default_options
      {
        has_headers: true,
        has_footer: false, # currently unused
        accessors:  [],
        name:       'Unnamed Table',
      }
    end

    # Create a table from a file.  
    # See {TableData} docs for a list of supported file types.
    #
    # @param [String] path
    #   The path to a file in one of the supported formats.
    #   
    # @param [Hash] options
    #   A list of options. Many are identical to {Table#initialize}'s options
    #   hash, but with the additional options :file_type and :table_class.
    #   The :data option is used by from_file and thus overridden and can't be
    #   used. For the same reason, :header, :footer and :body can't be used.
    #   
    # @option options [Symbol] :file_type
    #   The file type. Nil for auto-detection (which uses the extension of the
    #   filename), or one of :csv, :xls or :xlsx
    # @option options [String] :name
    #   The name of the table. Defaults to the basename of the file without the suffix.
    # @option options [Array<Symbol>, Hash<Symbol => Integer>, nil] :accessors
    #   A list of accessors for the columns. Allows accessing columns by that accessor.
    # @option options [true, false] :has_headers
    #   Whether the table has a header, defaults to true
    # @option options [true, false] :has_footer
    #   Whether the table has a footer, defaults to false
    #
    # @return [TableData::Table]
    #
    def self.from_file(path, options=nil)
      options ||= {}
      options[:table_class] ||= self
      options[:file_type]   ||= Detection.file_type_from_path(path)
      options[:name]        ||= File.basename(path).sub(/\.(?:csv|xlsx?)\z/, '')

      case options[:file_type]
        when :csv then Parser.parse_csv(path, options)
        when :xls then Parser.table_from_xls(path, options)
        when :xlsx then Parser.table_from_xlsx(path, options)
        else raise InvalidFileType, "Unknown file format #{options[:file_type].inspect}"
      end
    end

    # Create a table from a datastructure.
    #
    # @param [Array<Array>] data
    #   An array of arrays, representing rows -> cells.
    #
    # @param [Hash] options
    #   A list of options. Many are identical to {Table#initialize}'s options
    #   hash, but with the additional options :file_type and :table_class.
    #   The :data option is used by from_file and thus overridden and can't be
    #   used. For the same reason, :header, :footer and :body can't be used.
    #   
    # @option options [Symbol] :file_type
    #   The file type. Nil for auto-detection (which uses the extension of the
    #   filename), or one of :csv, :xls or :xlsx
    # @option options [Symbol] :table_class
    #   The class to use for this table. Defaults to self (TableData::Table)
    # @option options [String] :name
    #   The name of the table
    # @option options [Array<Symbol>, Hash<Symbol => Integer>, nil] :accessors
    #   A list of accessors for the columns. Allows accessing columns by that accessor.
    # @option options [true, false] :has_headers
    #   Whether the table has a header, defaults to true
    # @option options [true, false] :has_footer
    #   Whether the table has a footer, defaults to false
    #
    #
    def self.from_data(data, options=nil)
      new(options ? options.merge(data: data) : {data: data})
    end

    # @return [Array<Symbol>] An array of all named accessors
    attr_reader :accessors

    # @return [Hash<Symbol => Integer>] A hash mapping column accessor names to the column index
    attr_reader :accessor_columns

    # @return [Hash<Integer => Symbol>] A hash mapping column index to the column accessor names
    attr_reader :column_accessors

    # @private
    # The internal data structure. Do not modify.
    attr_reader :data

    # @return [String, nil] The name of the table
    attr_reader :name

    # Create a new table.
    #
    # @param [Hash] options
    #   A list of options. Mostly identical to {Table#initialize}'s options
    #   hash, but with the additional options :file_type and :table_class.
    # 
    # @option options [String] :name
    #   The name of the table
    # @option options [Array<Symbol>, Hash<Symbol => Integer>, nil] :accessors
    #   A list of accessors for the columns. Allows accessing columns by that accessor.
    # @option options [Symbol] :data
    #   An array of arrays with the table data. Mutually exclusive with
    #   :header, :body and :footer.
    # @option options [Symbol] :header
    #   An array with the header values. To be used together with :body and :footer.  
    #   Mutually exclusive with :data.  
    #   Automatically sets :has_headers to true.
    # @option options [Symbol] :body
    #   An array with the header values. To be used together with :header and :footer.  
    #   Mutually exclusive with :data.  
    #   Automatically sets :has_headers to false if :header is not also present.  
    #   Automatically sets :has_footer to false if :footer is not also present.  
    # @option options [Symbol] :footer
    #   An array with the header values. To be used together with :header and :body.  
    #   Mutually exclusive with :data.  
    #   Automatically sets :has_footer to true.
    # @option options [true, false] :has_headers
    #   Whether the table has a header, defaults to true
    # @option options [true, false] :has_footer
    #   Whether the table has a footer, defaults to false
    #
    def initialize(options=nil)
      options           = options ? self.class.default_options.merge(options) : self.class.default_options
      raise ArgumentError, "Invalid options: #{(options.keys-ValidOptions).inspect[1..-2]}" unless (options.keys-ValidOptions).empty?

      if options.has_key?(:data)
        raise "Must not mix :data with :header, :body or :footer" if options.has_key?(:header) || options.has_key?(:body) || options.has_key?(:footer)
        data = options.delete(:data)
      else
        data = []
        if options.has_key?(:header)
          data << options.delete(:header)
          options[:has_headers] = true
        end
        data.concat(options.delete(:body)) if options.has_key?(:body)
        if options.has_key?(:footer)
          data << options.delete(:footer)
          options[:has_footer] = true
        end
      end

      column_count      = data.first ? data.first.size : 0
      @name             = options.delete(:name)
      @has_headers      = options.delete(:has_headers) ? true : false
      @has_footer       = options.delete(:has_footer) ? true : false
      @data             = data
      @header_columns   = nil                        # used for cell access by header name, e.g. table[0]["Some Cellname"]
      self.accessors    = options.delete(:accessors) # used for cell access by accessor, e.g. table[0][:some_cell_accessor]
      @rows             = data.map.with_index { |row, index|
        raise InvalidColumnCount.new(index, row.size, column_count) if index > 0 && row.size != column_count
        raise ArgumentError, "Row must be provided as Array, but got #{row.class} in row #{index}" unless row.is_a?(Array)

        Row.new(self, index, row)
      }
    end

    # Automatically create accessors from the headers of the table.
    # It does that by downcasing the headers, replace everything which is not in [a-z0-9_] with an _,
    # replace all repeated occurrences of _ with a single _.
    #
    # @note
    #   The actual transformation algorithm might change in the future.
    def accessors_from_headers!
      raise "Can't define accessors from headers in a table without headers" unless @has_headers

      self.accessors = headers.map { |val| (val && !val.empty?) ? val.to_s.downcase.tr('^a-z0-9_', '_').squeeze('_').gsub(/\A_|_\z/, '').to_sym : nil }
    end

    # @param [Array<Symbol>, Hash<Symbol => Integer>, nil] accessors
    #
    # Define the name of the accessors used in TableData::Row.
    # If you pass in a Hash, it's supposed to be in the form of
    # {accessor_name: column_index}.
    def accessors=(accessors)
      @accessor_columns = {}
      case accessors
        when nil
          # nothing to do
        when Array
          accessors.each_with_index do |name, idx|
            @accessor_columns[name.to_sym] = idx if name
          end
        when Hash
          @accessor_columns = Hash[accessors.map { |name, index| [name.to_sym, index] }]
        else
          raise ArgumentError, "Expected nil, an Array or a Hash, but got #{accessors.class}"
      end
      @accessor_columns.freeze
      @column_accessors  = @accessor_columns.invert.freeze
      @accessors         = @column_accessors.values_at(*0..(@column_accessors.keys.max || -1)).freeze
    end

    # @return [Integer] The number of rows, excluding headers and footer
    def size
      result = @data.size - (@has_headers ? 1 : 0) - (@has_footer ? 1 : 0)

      result < 0 ? 0 : result
    end
    alias length size

    # @return [Integer, nil] The number of columns. Nil if no rows are present.
    def column_count
      @data.first ? @data.first.size : nil
    end

    # Array#[] like access to the rows in the body (excluding headers and
    # footer) of the table.
    #
    # @return [Array<TableData::Row>]
    def [](*args)
      body[*args]
    end

    # Access the value of a cell directly
    #
    # @note This method's signature will probably change soon.
    #
    # TODO: Figure out how to properly deal with out-of-bounds access.
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

    # @return [TableData::Row]
    #   The row at the given row number (zero based). Includes headers and footer.
    def row(row)
      @rows[row]
    end

    # @return [Symbol, nil]
    #   The accessor defined for the given column index.
    def column_accessor(index)
      @column_accessors[index]
    end

    # @return [String, nil]
    #   The name defined for the given column index.  
    #   The name is determined by the column's header.
    #   Returns nil if the table has no headers.
    def column_name(index)
      h = headers

      h && h.at(index)
    end

    # @return [Array<TableData::Column>]
    #   An array with the columns of this table
    def columns
      Array.new(column_count) { |col| column(col) }
    end

    # @return [TableData::Column]
    #   The column at the given index, accessor or name.
    def column(index)
      Column.new(self, index_for_column(index))
    end

    # @return [Integer, nil]
    #   The index for the given column-index, -accessor or -name.
    def index_for_column(column)
      case column
        when Integer then column
        when Symbol  then index_for_accessor(column)
        when String  then index_for_header(column)
        else raise InvalidColumnSpecifier, "Invalid index type, expected Symbol, String or Integer, but got #{column.class}"
      end
    end

    # @return [Integer, nil]
    #   The index for the given column-accessor.
    def index_for_accessor(name)
      @accessor_columns[name.to_sym]
    end

    # @return [Integer, nil]
    #   The index for the given column-name.
    def index_for_header(name)
      if @has_headers && @data.first then
        @header_columns ||= Hash[@data.first.each_with_index.to_a]
        @header_columns[name]
      else
        nil
      end
    end

    # @return [true, false]
    #   Whether accessors have been defined for this table
    def accessors?
      !@accessors.empty?
    end

    # @return [true, false]
    #   Whether this table has headers
    def headers?
      @has_headers
    end

    # @return [TableData::Row, nil]
    #   The header row, if the table has headers and the header row is present.
    #   Nil otherwise.
    def headers
      headers? ? @rows.first : nil
    end

    # @return [true, false]
    #   Whether this table has a footer
    def footer?
      @has_footer
    end

    # @return [TableData::Row, nil]
    #   The header row, if the table has a footer and the footer row is present.
    #   Nil otherwise.
    def footer
      !footer? || (headers? && @rows.size < 2) ? nil : @rows.last
    end

    # @return [Array<TableData::Row>]
    #   All rows except header and footer.
    def body
      end_offset = footer? ? -2 : -1

      if headers?
        @rows.empty? ? [] : @rows[1..end_offset]
      else
        @rows[0..end_offset]
      end
    end

    # Append a row to the table.
    #
    # @param [Array, #to_ary] row
    #   The row to append to the table
    #
    # @return [self]
    def <<(row)
      index  = @data.size
      begin
        row = row.to_ary
      rescue NoMethodError
        raise ArgumentError, "Row must be provided as Array or respond to `to_ary`, but got #{row.class} in row #{index}" unless row.respond_to?(:to_ary)
        raise
      end
      raise InvalidColumnCount.new(index, row.size, column_count) if @data.first && row.size != @data.first.size

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
      return enum_for(__method__) unless block_given?

      column_count.times do |i|
        yield column(i)
      end

      self
    end

    # Returns a deep copy of the tables internal datastructure.
    #
    # TODO: figure whether this method is needed.
    def to_nested_array
      to_a.map(&:to_a)
    end

    # @note This method might be changed
    #
    # @return [Array<Array>]
    #   A deep copy of the tables internal datastructure, an Array of row array.
    def to_a
      @data
    end

    # @return [true, false]
    #   Whether this table has the same content as `other`.
    #   Uses the #data method to get the contents.
    #   If other has no #data method, the comparison is false.
    def ==(other)
      (
        other.is_a?(TableData::Table) &&
        other.name      == @name &&
        other.headers?  == @has_headers &&
        other.footer?   == @has_footer &&
        other.accessors == @accessors &&
        other.data      == data
      )
    end

    # @return [TableData::Presenter]
    def format(format_id, options=nil)
      Presenter.present(self, format_id, options)
    end

    # See Object#inspect
    def inspect
      sprintf "#<%s headers: %p, footer: %p, cols: %s, rows: %d>", self.class, headers?, footer?, column_count || '-', size
    end
  end
end
