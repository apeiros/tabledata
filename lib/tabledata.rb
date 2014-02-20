# encoding: utf-8

require 'tabledata/version'
require 'tabledata/table'
require 'tabledata/tables'
require 'tabledata/exceptions'

# Tables
# Read tabular data from various formats.
module TableData
  module_function

  # @see TableData::Table.from_file Full documentation
  #
  # @return [TableData::Table]
  def table_from_file(*args)
    Table.from_file(*args)
  end

  # @see TableData::Table.from_data Full documentation
  #
  # @return [TableData::Table]
  def table_from_data(*args)
    Table.from_data(*args)
  end

  # @see TableData::Tables.from_file Full documentation
  #
  # @return [TableData::Tables]
  def tables_from_file(*args)
    Tables.from_file(*args)
  end

  def tables_from_data(*args)
    Tables.from_data(*args)
  end

  def require_library(name, message)
    $stdout, oldstdout = StringIO.new, $stdout
    require name
  rescue LoadError => error
    if error.message =~ /cannot load such file -- #{Regexp.escape(name)}/ then
      raise LibraryMissingError.new(name, message, error)
    else
      raise
    end
  ensure
    $stdout = oldstdout
  end
end
