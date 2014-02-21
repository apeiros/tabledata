suite "TableData::Table" do
  test 'Table::from_data' do
    assert_kind_of TableData::Table, TableData::Table.from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_header: true)
    assert_kind_of TableData::Table, TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_header: true)

    table1 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_header: true)
    table2 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_header: false)

    assert table1.headers?
    assert !table2.headers?

    assert_equal %w[H1 H2 H3], table2[0].to_a
    assert_equal [1,2,3],      table2[1].to_a
    assert_equal [:a, :b, :c], table2[2].to_a
  end

  test 'Table::from_file' do
    assert_kind_of TableData::Table, TableData::Table.from_file(test_file('test1.xls'))
    assert_kind_of TableData::Table, TableData.table_from_file(test_file('test1.xls'))

    expected = [
      ["First Name", "Last Name", "Age", "Birthday",            "Profession",   "Street",             "Street Name",    "Street Number", "ZIP",   "City",     "E-Mail"],
      ["Peter",      "Parker",    30.0,  Date.civil(1973,1,31), "Photographer", "410 Chelsea Street", "Chelsea Street", 410.0,           10307.0, "New York", "peter.parker@example.com"],
    ]
    table1 = TableData.table_from_file(test_file('test1.xls'))
    table2 = TableData.table_from_file(test_file('test1.xlsx'))

    assert_equal expected, table1.to_a
    assert_equal expected, table2.to_a
  end

  test 'Table::new' do
    header = %w[H1 H2 H3]
    body   = [[1,2,3]]
    footer = [:a, :b, :c]
    data   = [header]+body+[footer]
    table1 = TableData::Table.new
    table2 = TableData::Table.new data: data, has_header: false, has_footer: true, accessors: [:a, :b, :c], name: 'testtable'
    table3 = TableData::Table.new data: data, has_header: true, has_footer: false, accessors: [:a, :b, :c], name: 'testtable'
    table4 = TableData::Table.new header: header, body: body, footer: footer

    assert_kind_of TableData::Table, table1
    assert_kind_of TableData::Table, table2
    assert_kind_of TableData::Table, table3

    assert_equal 'Unnamed Table', table1.name
    assert_equal true,            table1.headers?
    assert_equal false,           table1.footer?
    assert_equal [],              table1.accessors
    assert_equal nil,             table1.headers
    assert_equal [],              table1.body
    assert_equal nil,             table1.footer
    assert_equal [],              table1.to_a

    assert_equal 'testtable',    table2.name
    assert_equal false,          table2.headers?
    assert_equal true,           table2.footer?
    assert_equal [:a, :b, :c],   table2.accessors
    assert_equal nil,            table2.headers
    assert_equal [header]+body,  table2.body.map(&:to_a)
    assert_equal footer,         table2.footer.to_a
    assert_equal data,           table2.to_a

    assert_equal 'testtable',    table3.name
    assert_equal true,           table3.headers?
    assert_equal false,          table3.footer?
    assert_equal [:a, :b, :c],   table3.accessors
    assert_equal header,         table3.headers.to_a
    assert_equal body+[footer],  table3.body.map(&:to_a)
    assert_equal nil,            table3.footer
    assert_equal data,           table3.to_a

    assert_equal 'Unnamed Table', table4.name
    assert_equal true,            table4.headers?
    assert_equal true,            table4.footer?
    assert_equal [],              table4.accessors
    assert_equal header,          table4.headers.to_a
    assert_equal body,            table4.body.map(&:to_a)
    assert_equal footer,          table4.footer.to_a
    assert_equal data,            table4.to_a
  end

  test 'Table#accessors' do
    accessors = [:a, :b, :c]
    table     = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], accessors: accessors)

    assert_equal accessors, table.accessors
  end

  test 'Table#accessors' do
    accessors2 = []
    accessors3 = [:a, :b, :c]
    accessors4 = [:a, nil, :c]
    table1     = TableData::Table.new
    table2     = TableData::Table.new(accessors: nil)
    table3     = TableData::Table.new(accessors: accessors3)
    table4     = TableData::Table.new(accessors: accessors4)

    assert_equal [],         table1.accessors
    assert_equal accessors2, table2.accessors
    assert_equal accessors3, table3.accessors
    assert_equal accessors4, table4.accessors
  end

  test 'Table#accessors=' do
    accessors2       = []
    accessors3       = [:a, :b, :c]
    accessors4       = [:a, nil, :c]
    table1           = TableData::Table.new
    table2           = TableData::Table.new
    table3           = TableData::Table.new
    table4           = TableData::Table.new
    table1.accessors = nil
    table2.accessors = accessors2
    table3.accessors = accessors3
    table4.accessors = accessors4

    assert_equal [],         table1.accessors
    assert_equal accessors2, table2.accessors
    assert_equal accessors3, table3.accessors
    assert_equal accessors4, table4.accessors
  end

  test 'Table#accessor_columns' do
    accessors1        = nil
    accessors2        = [:a, :b, :c]
    accessors3        = [:a, nil, :c]
    accessor_columns1 = {}
    accessor_columns2 = {a: 0, b: 1, c: 2}
    accessor_columns3 = {a: 0, c: 2}
    table1            = TableData::Table.new(accessors: accessors1)
    table2            = TableData::Table.new(accessors: accessors2)
    table3            = TableData::Table.new(accessors: accessors3)

    assert_equal accessor_columns1, table1.accessor_columns
    assert_equal accessor_columns2, table2.accessor_columns
    assert_equal accessor_columns3, table3.accessor_columns
  end

  test 'Table#column_accessors' do
    accessors1        = nil
    accessors2        = [:a, :b, :c]
    accessors3        = [:a, nil, :c]
    column_accessors1 = {}
    column_accessors2 = {0 => :a, 1 => :b, 2 => :c}
    column_accessors3 = {0 => :a, 2 => :c}
    table1            = TableData::Table.new(accessors: accessors1)
    table2            = TableData::Table.new(accessors: accessors2)
    table3            = TableData::Table.new(accessors: accessors3)

    assert_equal column_accessors1, table1.column_accessors
    assert_equal column_accessors2, table2.column_accessors
    assert_equal column_accessors3, table3.column_accessors
  end

  test 'Table#name' do
    table = TableData::Table.new(name: 'Just something')

    assert_equal 'Just something', table.name
  end

  test 'Table#accessors_from_headers!' do
    table = TableData::Table.new header: ['Header', 'Just Something', '', 'Weird%Chars$']
    table.accessors_from_headers!

    assert_equal [:header, :just_something, nil, :weird_chars], table.accessors
  end

  test 'Table#size' do
    data   = [%w[H1 H2 H3], [1,2,3], [:a, :b, :c]]
    table1 = TableData::Table.new data: data, has_header: false, has_footer: false
    table2 = TableData::Table.new data: data, has_header: true,  has_footer: false
    table3 = TableData::Table.new data: data, has_header: false, has_footer: true
    table4 = TableData::Table.new data: data, has_header: true,  has_footer: true

    assert_equal 3, table1.size
    assert_equal 2, table2.size
    assert_equal 2, table3.size
    assert_equal 1, table4.size
  end

  test 'Table#column_count' do
    table1 = TableData::Table.new
    table2 = TableData::Table.new header: %w[]
    table3 = TableData::Table.new header: %w[H1 H2 H3]

    assert_equal nil, table1.column_count
    assert_equal 0,   table2.column_count
    assert_equal 3,   table3.column_count
  end

  test 'Table#[]' do
    table = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_header: true)

    assert_kind_of TableData::Row, table[0]
    assert_kind_of NilClass,       table[3]

    assert_equal [1,2,3], table[0].to_a
  end

  test 'Table#cell' do
    table = TableData.table_from_data([%w[H1 H2 H3], [:a, :b, :c]], has_header: true)

    assert_equal 'H1', table.cell(0, 0)
    assert_equal :b,   table.cell(1, 1)

    # TODO: I'm not sure how Table#cell should work with regards to out-of-bounds access
  end

  test 'Table#row' do
    table = TableData.table_from_data([%w[H1 H2 H3], [:a, :b, :c]], has_header: true)

    assert_kind_of TableData::Row, table.row(0)
    assert_equal   %w[H1 H2 H3],   table.row(0).to_a

    # TODO: I'm not sure how Table#row should work with regards to out-of-bounds access
  end

  test 'Table#column_accessor' do
    table = TableData::Table.new(accessors: [:a, nil, :c])

    assert_equal :a,  table.column_accessor(0)
    assert_equal nil, table.column_accessor(1)
    assert_equal :c,  table.column_accessor(2)
    assert_equal nil, table.column_accessor(3)
  end
end
