# encoding: utf-8

require 'stringio'
require 'tabledata/version'
require 'tabledata/table'
require 'tabledata/tables'
require 'tabledata/dsls/table_definition'
require 'tabledata/exceptions'

# Handle tabular data
#
# TableData supports the following file formats:
# * .xls Excel files (:xls)
# * .xlsx Excel files (:xlsx)
# * .csv Comma Separated Values (:csv)
module TableData
  module_function

  # @see TableData::Table#initialize Full documentation
  # @see TableData::Table.from_file Full documentation
  #
  # If a :file option is present, it uses #{TableData::Table.from_file},
  # otherwise #{TableData::Table.new}.
  #
  # @return [TableData::Table]
  def table(options)
    if options.has_key?(:file)
      options = options.dup
      path   = options.delete(:file)

      Table.from_file(path, options)
    else
      Table.new(options)
    end
  end

  # @see TableData::Tables#initialize Full documentation
  # @see TableData::Tables.from_file Full documentation
  #
  # If a :file option is present, it uses #{TableData::Table.from_file},
  # otherwise #{TableData::Tables.new}.
  #
  # @return [TableData::Tables]
  def tables(options)
    if options.has_key?(:file)
      options = options.dup
      path   = options.delete(:file)

      Tables.from_file(path, options)
    else
      Tables.new(options)
    end
  end

  def define_table(*args, &block)
    Dsls::TableDefinition.new(*args, &block).definition.create_table_class
  end

  # @private
  # A helper method to require optional dependencies and provide better informing
  # errors if such a dependency should be missing.
  # Also silences $stdout during the require.
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
