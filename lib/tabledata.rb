# encoding: utf-8

require 'tabledata/version'
require 'tabledata/table'

# Tables
# Read tabular data from various formats.
module TableData
  module_function

  # @see TableData::Table::from_file Full documentation
  def table_from_file(path, options=nil)
    Table.from_file(path, options)
  end

  # NOT IMPLEMENTED!
  #
  # @return [TableData::Tables]
  def tables_from_file(path)
    raise "Unimplemented"
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
