# encoding: utf-8

module Tables
  class Column
    attr_reader :table
    attr_reader :index

    include Enumerable

    def initialize(table, index)
      @table  = table
      @index  = index
    end

    def header
      @table.column_header(@index)
    end

    def accessor
      @table.column_accessor(@index)
    end

    def [](*args)
      rows = @table.rows[*args]

      if rows.is_a?(Array) # slice
        rows.map { |row| row.at(@index) }
      else # single row
        rows.at(@index)
      end
    end

    def each
      return enum_for(__method__) unless block_given?

      @table.each do |row|
        yield row.at(@index)
      end
    end

    def to_a
      @table.map { |row| row.at_index(@index) }
    end
  end
end
