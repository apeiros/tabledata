README
======



Summary
-------

Read tabular data from various formats, like Excel .xls, Excel .xlsx, CSV.



Installation
------------

`gem install tabledata`



Usage
-----

    table1 = TableData.table file: 'some/excelfile.xls'
    table2 = TableData.table header: %w[header1 header2], body: [['value1', 'value2']]
    table3 = TableData.table data: [['header1', 'header2'], ['value1', 'value2']], accessors: [:cell1, :cell2]
    table3.fetch_cell(1, :cell1) # => 'value1'
    table3.row(1).cell1          # => 'value1'
    table3[0][0]                 # => 'value1'



Description
-----------

Read tabular data from various formats.



Weak Dependencies
-----------------

* The 'roo' gem for .xls/.xlsx Excel file import
* The 'spreadsheet' gem for .xls Excel file export
* The 'prawn' gem for PDF export
* The 'nokogiri' gem for HTML import



Links
-----

* [Online API Documentation](http://rdoc.info/github/apeiros/tabledata/master/frames)
* [Public Repository](https://github.com/apeiros/tabledata)
* [Bug Reporting](https://github.com/apeiros/tabledata/issues)
* [RubyGems Site](https://rubygems.org/gems/tabledata)



License
-------

You can use this code under the {file:LICENSE.txt BSD-2-Clause License}, free of charge.
If you need a different license, please ask the author.
