# encoding: utf-8

require 'table_data/exceptions'

module TableData

  # Represents a row in a table and provides an easy way to enumerate and access
  # values in a row.
  #
  # If your table defines accessors, you can access columns by using methods of that name.
  #
  # @example
  #     table = TableData.table body: [[1,2,3], [4,5,6]], accessors: %i[foo bar baz]
  #     table[0].foo     # => 1
  #     table[1].baz     # => 6
  #     table[1].bar = 9
  #
  # @note
  #   The row data is referenced. If you mutate the table, adding a row to it,
  #   this row instance's data will not change. Its index will be off.
  class Row

    # @return [Tabledata::Table] The table this column belongs to.
    attr_reader :table

    # @return [Integer] The row index in the table. Zero based, including header and footer.
    attr_reader :index

    # @return [Array] The row's data. It's the internal structure, don't modify it directly.
    attr_reader :data

    include Enumerable

    # @param [Tabledata::Table] table
    #   The table this column belongs to.
    # @param [Integer] index
    #   The index of the column in the table.
    # @param [Array] data
    #   The data of the row. If set to nil, it is fetched from the table.
    def initialize(table, index, data=nil)
      @table  = table
      @index  = index
      @data   = data || @table.data[index]
    end

    # Iterate over each cell in this row
    def each(&block)
      @data.each(&block)
    end

    # Tries to return the value of the column identified by index, corresponding accessor or header.
    # It throws an IndexError exception if the referenced index lies outside of the array bounds.
    # This error can be prevented by supplying a second argument, which will act as a default value.
    # 
    # Alternatively, if a block is given it will only be executed when an invalid
    # index is referenced.  Negative values of index count from the end of the
    # array.
    def fetch(column, *default_value, &default_block)
      raise ArgumentError, "Must only provide at max one default value or one default block" if default_value.size > (block_given? ? 0 : 1)

      index = case column
        when Symbol then @table.index_for_accessor(column)
        when String then @table.index_for_header(column)
        when Integer then column
        else raise InvalidColumnSpecifier, "Invalid index type, expected Symbol, String or Integer, but got #{column.class}"
      end

      @data.fetch(index, *default_value, &default_block)
    end

    # Convenience access of values in the row.
    # Can either be used like Array#[], i.e. it accepts an offset,
    # an offset + length, or an offset-to-offset range.
    # Alternatively you can use a Symbol, if it's a valid accessor in this table.
    # And the last variant is using a String, which will access the value of
    # the corresponding header.
    #
    # @return [Array, Object] Either the value of a given cell, or an array of values.
    # 
    # @see #slice for a faster way to use ranges or offset+length
    # @see #at_accessor for a faster way to access by name
    # @see #at_index for a faster way to access by index
    # @see #at_header for a faster way to access by header value
    def [](a,b=nil)
      if b || a.is_a?(Range) then
        slice(a,b)
      else
        at(a)
      end
    end

    # Array-like access to row-data.
    #
    # @example
    #     table = TableData.table body: [[:a,:b,:c]], accessors: %i[foo bar baz]
    #     row   = table.row(0)
    #     row.slice(1)      # => :b
    #     row.slice(0, 2)   # => [:a, :b]
    #     row.slice(-2, 2)  # => [:b, :c]
    #     row.slice(1..2)   # => [:b, :c]
    #     row.slice(0..-2)  # => [:a, :b]
    #     row.slice(-2..-1) # => [:b, :c]
    #     row.slice(:foo)   # !> TypeError
    #     row.slice("foo")  # !> TypeError
    #
    # @see #[] Generic cell access.
    def slice(*args)
      @data[*args]
    end

    # Access a single cell by either index, index-range, accessor or header-name.
    #
    # @example
    #     table = TableData.table header: %w[x y z], body: [[:a,:b,:c]], accessors: %i[foo bar baz]
    #     row   = table.row(1)
    #     row.at(0)    # => :a
    #     row.at(:foo) # => :a
    #     row.at("x")  # => :a
    def at(column)
      case column
        when Symbol  then at_accessor(column)
        when String  then at_header(column)
        when Integer then at_index(column)
        when Range   then @data[column]
        else raise InvalidColumnSpecifier, "Invalid index type, expected Symbol, String or Integer, but got #{column.class}"
      end
    end

    # Access a single cell by its corresponding header-name.
    # This method is faster than the generic methods TableData::Row#[] and #at.
    #
    # @example
    #     table = TableData.table header: %w[x y z], body: [[:a,:b,:c]], accessors: %i[foo bar baz]
    #     row   = table.row(1)
    #     row.at_header("x")  # => :a
    def at_header(name)
      index = @table.index_for_header(name)
      raise InvalidColumnName, "No column named #{name}" unless index

      @data[index]
    end

    # Access a single cell by its corresponding accessor.
    # This method is faster than the generic methods TableData::Row#[] and #at.
    #
    # @example
    #     table = TableData.table header: %w[x y z], body: [[:a,:b,:c]], accessors: %i[foo bar baz]
    #     row   = table.row(1)
    #     row.at_accessor(:foo) # => :a
    def at_accessor(name)
      index = @table.index_for_accessor(name)
      raise InvalidColumnAccessor, "No column named #{name}" unless index

      @data[index]
    end

    # Access a single cell by its index.
    # This method is faster than the generic methods TableData::Row#[] and #at.
    #
    # @example
    #     table = TableData.table header: %w[x y z], body: [[:a,:b,:c]], accessors: %i[foo bar baz]
    #     row   = table.row(1)
    #     row.at_index(0)    # => :a
    def at_index(index)
      @data.at(index)
    end

    # Access multiple values by either index, index-range, accessor or header-name.
    # @example
    #     table = TableData.table header: %w[x y z], body: [[:a,:b,:c]], accessors: %i[foo bar baz]
    #     row   = table.row(1)
    #     row.values_at(2,1,0)    # => [:c, :b, :a]
    #     row.values_at(:foo,'z') # => [:a, :c]
    #     row.values_at(0..1, 2..-1) # => [:a, :b, :c]
    def values_at(*columns)
      result = []
      columns.each do |column|
        data = at(column)
        if column.is_a?(Range)
          result.concat(data) if data
        else
          result << data
        end
      end

      result
    end

    # @return [Integer] The number of cells in this row.
    def size
      @data.size
    end
    alias length size

    # @return [Hash]
    #   A hash with the accessors as key and the cell values as values.
    def to_h
      Hash[@table.accessor_columns.map { |accessor, index| [accessor, @data[index]] }]
    end

    # @return [Array]
    #   The row values as array
    def to_a
      @data.dup
    end
    alias to_ary to_a

    # @private
    # See Object#respond_to_missing?
    def respond_to_missing?(name, include_private)
      if name =~ /=$/
        @table.index_for_accessor(name[0..-2].to_sym) ? true : false
      else
        @table.index_for_accessor(name) ? true : false
      end
    end

    # Allow reading and writing cell values by their accessor name.
    def method_missing(name, *args, &block)
      return super unless @table.accessors?

      name              =~ /^(\w+)(=)?$/
      name_mod, assign  = $1, $2
      index             = @table.index_for_accessor(name_mod)
      arg_count         = assign ? 1 : 0

      return super unless index

      raise ArgumentError, "Wrong number of arguments (#{args.size} for #{arg_count})" if args.size > arg_count

      if assign then
        @data[index] = args.first
      else
        @data[index]
      end
    end

    # @private
    # See Object#inspect
    def inspect
      sprintf "%s%p", self.class, to_a
    end
  end
end
