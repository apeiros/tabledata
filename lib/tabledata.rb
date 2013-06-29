# encoding: utf-8

require 'tabledata/version'
require 'tabledata/table'

# Tables
# Read tabular data from various formats.
module TableData
  module_function

  def table_from_file(path, options=nil)
    Table.from_file(path, options)
  end

  def tables_from_file(path)
    raise "Unimplemented"
  end
end