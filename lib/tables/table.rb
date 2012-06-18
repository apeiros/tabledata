# encoding: utf-8

require 'tables/parser'
require 'tables/row'
require 'tables/column'

module Tables
  class Table
    include Enumerable

    DefaultOptions = {
      has_headers: true,
      accessors:   [],
    }

    def self.from_file(path, options=nil)
      case path
        when /\.csv$/ then Parser.parse_csv(path, options)
        when /\.xls$/ then Parser.parse_xls(path, options)
        when /\.xlsx$/ then Parser.parse_xlsx(path, options)
        else raise ArgumentError, "Unknown file format"
      end
    end

    attr_reader :accessors

    def initialize(options=nil)
      options           = options ? DefaultOptions.merge(options) : DefaultOptions.dup
      @has_headers      = options.delete(:has_headers) ? true : false
      @data             = []
      @column_count     = nil
      @accessors        = (options.delete(:accessors) || []).map { |n| n.to_sym }
      @accessor_columns = {}
      @header_columns   = nil

      @accessors.each_with_index do |name, idx|
        @accessor_columns[name] = idx
      end
    end

    def [](*args)
      body[*args]
    end

    def column_count
      @data.first && @data.first.size
    end

    def column_accessor(index)
      @accessors && @accessors.at(index)
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
      if @has_headers && @data.first then
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
      @has_headers
    end

    def headers
      headers? ? @data.first : nil
    end

    def body
      headers? ? @data[1..-1] : @data
    end

    def <<(row)
      @data << Row.new(self, @data.size, row)
      raise ArgumentError, "Invalid column count (#{@data.first.size} expected, but has #{row.size})" unless row.size == @data.first.size

      self
    end

    def each(&block)
      body.each(&block)
    end

    def to_nested_array
      to_a.map(&:to_a)
    end

    def to_a
      @data
    end
  end
end
