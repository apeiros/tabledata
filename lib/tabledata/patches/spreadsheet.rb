# encoding: utf-8



require 'spreadsheet'
require 'stringio'



class Spreadsheet::Workbook
  def to_string
    StringIO.new.tap { |string_io| write(string_io) }.string
  end
end
