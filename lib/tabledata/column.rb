# encoding: utf-8

module TableData

  # Represents a column in a table and provides an easy way to enumerate
  # values in a column.
  #
  # @note
  #   The column data is not copied. It is retrieved from the table via the columns index.
  #   If you mutate the table, adding a column to it, this column instance's data will change.
  class Column

    # @return [Tabledata::Table] The table this column belongs to.
    attr_reader :table

    # @return [Integer] The column index in the table, zero based.
    attr_reader :index

    include Enumerable

    # @param [Tabledata::Table] table
    #   The table this column belongs to.
    # @param [Integer] index
    #   The index of the column in the table.
    def initialize(table, index)
      @table  = table
      @index  = index
    end

    # @return [Object]
    #   The header value of this column (if available)
    def header
      @table.column_header(@index)
    end

    # @return [Symbol, nil]
    #   The accessor for this column
    def accessor
      @table.column_accessor(@index)
    end

    # Similar to Tabledata::Table#[], but only returns values for this column.
    # Provides array like access to this column's data. Only considers body
    # values (i.e., does not consider header and footer).
    #
    # @return [Array, Object]
    def [](*args)
      rows = @table.body[*args]

      if rows.is_a?(Array) # slice
        rows.map { |row| row[@index] }
      else # single row
        rows[@index]
      end
    end

    # Iterate over all body values (i.e. no header or footer) in the column.
    #
    # @see TableData::Column#each_value
    #   A method which iterates over all values, including header and footer.
    #
    # @yield [value]
    # @yieldparam [Object]
    #
    # @return [self]
    def each
      return enum_for(__method__) unless block_given?

      @table.each do |row|
        yield(row[@index])
      end

      self
    end

    # Iterate over all values in the column, including header and footer.
    #
    # @see TableData::Table#each
    #   A method which iterates only over body values, excluding header and footer.
    #
    # @yield [value]
    # @yieldparam [Object]
    #
    # @return [self]
    def each_value
      return enum_for(__method__) unless block_given?

      @table.data.each do |row|
        yield(row[@index])
      end

      self
    end

    # @return [Integer] The number of values, excluding headers and footer
    def size
      @table.size
    end
    alias length size

    # @param [Hash] options
    # @option options [Symbol] :include_header
    #   Defaults to true. If set to false, the header (if present) is excluded.
    # @option options [Symbol] :include_footer
    #   Defaults to true. If set to false, the footer (if present) is excluded.
    #
    # @return [Array] All values in the column, including header and footer.
    def to_a(options=nil)
      data = @table.data.transpose[@index]

      if options
        start_offset = options[:include_header] && @table.headers? ? 1 : 0
        end_offset   = options[:include_footer] && @table.footer? ? -2 : -1

        data[start_offset..end_offset]
      else
        data
      end
    end

    # @param [Tabledata::Column, Array, #to_ary, Object] other
    #
    # @return [true, false]
    #   Whether the values in this column is equal to the values in `other`  
    #   False if other is neither a Tabledata::Column, Array, or Object
    #   responding to #to_ary.
    def ==(other)
      if other.is_a?(Tabledata::Column)
        other.to_a == @table.data.transpose[@index]
      elsif other.is_a?(Array)
        other == @table.data.transpose[@index]
      elsif other.respond_to?(:to_ary)
        other.to_ary == @table.data.transpose[@index]
      else
        false
      end
    end

    # @param [Object]
    #
    # @return [true, false] Whether `other` is also a column and contains the same data.
    def eql?(other)
      other.is_a?(TableData::Column) && @table.data.transpose[@index] == other.to_a
    end

    # See Object#hash
    def hash
      [TableData::Column, to_a].hash
    end
  end
end
