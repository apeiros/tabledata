suite "TableData::Table" do
  test 'Table::from_data' do
    assert_kind_of TableData::Table, TableData::Table.from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true)
    assert_kind_of TableData::Table, TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true)

    table1 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true)
    table2 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false)

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
    table2 = TableData::Table.new data: data, has_headers: false, has_footer: true, accessors: [:a, :b, :c], name: 'testtable'
    table3 = TableData::Table.new data: data, has_headers: true, has_footer: false, accessors: [:a, :b, :c], name: 'testtable'
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
    accessors2 = []
    accessors3 = [:a, :b, :c]
    accessors4 = [:a, nil, :c]
    accessors5 = [nil, nil, nil]
    table1     = TableData::Table.new
    table2     = TableData::Table.new(accessors: nil)
    table3     = TableData::Table.new(accessors: accessors3)
    table4     = TableData::Table.new(accessors: accessors4)
    table5     = TableData::Table.new(accessors: accessors5)

    assert_equal [],         table1.accessors
    assert_equal accessors2, table2.accessors
    assert_equal accessors3, table3.accessors
    assert_equal accessors4, table4.accessors
    assert_equal [],         table5.accessors
  end

  test 'Table#accessors=' do
    accessors2       = []
    accessors3       = [:a, :b, :c]
    accessors4       = [:a, nil, :c]
    accessors5 = [nil, nil, nil]
    table1           = TableData::Table.new
    table2           = TableData::Table.new
    table3           = TableData::Table.new
    table4           = TableData::Table.new
    table5           = TableData::Table.new
    table1.accessors = nil
    table2.accessors = accessors2
    table3.accessors = accessors3
    table4.accessors = accessors4
    table5.accessors = accessors5

    assert_equal [],         table1.accessors
    assert_equal accessors2, table2.accessors
    assert_equal accessors3, table3.accessors
    assert_equal accessors4, table4.accessors
    assert_equal [],         table5.accessors
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
    table1 = TableData::Table.new data: data, has_headers: false, has_footer: false
    table2 = TableData::Table.new data: data, has_headers: true,  has_footer: false
    table3 = TableData::Table.new data: data, has_headers: false, has_footer: true
    table4 = TableData::Table.new data: data, has_headers: true,  has_footer: true

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
    table = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true)

    assert_kind_of TableData::Row, table[0]
    assert_kind_of NilClass,       table[3]

    assert_equal [1,2,3], table[0].to_a
  end

  test 'Table#cell' do
    table = TableData.table_from_data([%w[H1 H2 H3], [:a, :b, :c]], has_headers: true)

    assert_equal 'H1', table.cell(0, 0)
    assert_equal :b,   table.cell(1, 1)

    # TODO: I'm not sure how Table#cell should work with regards to out-of-bounds access
  end

  test 'Table#row' do
    table = TableData.table_from_data([%w[H1 H2 H3], [:a, :b, :c]], has_headers: true)

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

  test 'Table#column_name' do
    table = TableData.table_from_data([%w[H1 H2 H3], [:a, :b, :c]], has_headers: true)

    assert_equal 'H1', table.column_name(0)
    assert_equal 'H2', table.column_name(1)
    assert_equal 'H3', table.column_name(2)
    assert_equal nil,  table.column_name(3)
  end

  test 'Table#columns' do
    table = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]])

    assert_kind_of Array,             table.columns
    assert_equal   3,                 table.columns.size
    assert_kind_of TableData::Column, table.columns.first
    assert_equal   ['H1', 1, :a],     table.columns[0].to_a
    assert_equal   ['H2', 2, :b],     table.columns[1].to_a
    assert_equal   ['H3', 3, :c],     table.columns[2].to_a
  end

  test 'Table#column' do
    table = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true, accessors: [:a, :b, :c])

    assert_kind_of TableData::Column, table.column(1)
    assert_kind_of TableData::Column, table.column(:b)
    assert_kind_of TableData::Column, table.column('H2')
    assert_equal   ['H2', 2, :b],     table.column(1).to_a
    assert_equal   table.column(1),   table.column(:b)
    assert_equal   table.column(1),   table.column('H2')
    assert_equal   table.column(:b),  table.column('H2')
  end

  test 'Table#index_for_accessor' do
    table = TableData::Table.new accessors: [:a, :b, :c]

    assert_equal 0,   table.index_for_accessor(:a)
    assert_equal 1,   table.index_for_accessor(:b)
    assert_equal 2,   table.index_for_accessor(:c)
    assert_equal nil, table.index_for_accessor(:d)
  end

  test 'Table#index_for_header' do
    table = TableData::Table.new header: %w[H1 H2 H3], has_headers: true

    assert_equal 0,   table.index_for_header('H1')
    assert_equal 1,   table.index_for_header('H2')
    assert_equal 2,   table.index_for_header('H3')
    assert_equal nil, table.index_for_header('H4')
  end

  test 'Table#accessors?' do
    assert !TableData::Table.new(accessors: nil).accessors?
    assert !TableData::Table.new(accessors: []).accessors?
    assert !TableData::Table.new(accessors: [nil, nil, nil]).accessors?
    assert TableData::Table.new(accessors: [:a, :b, :c]).accessors?
  end

  test 'Table#headers?' do
    assert !TableData::Table.new(has_headers: false).headers?
    assert TableData::Table.new(has_headers: true).headers?
  end

  test 'Table#headers' do
    assert_equal nil,          TableData::Table.new(has_headers: false).headers
    assert_equal nil,          TableData::Table.new(data: [], has_headers: true).headers
    assert_equal %w[H1 H2 H3], TableData::Table.new(header: %w[H1 H2 H3]).headers.to_a
  end

  test 'Table#footer?' do
    assert !TableData::Table.new(has_footer: false).footer?
    assert TableData::Table.new(has_footer: true).footer?
  end

  test 'Table#footer' do
    assert_equal nil,          TableData::Table.new(has_headers: false).headers
    assert_equal nil,          TableData::Table.new(data: [], has_headers: true).headers
    assert_equal %w[H1 H2 H3], TableData::Table.new(header: %w[H1 H2 H3]).headers.to_a
  end

  test 'Table#body' do
    table1 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: false)
    table2 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: true)
    table3 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: false)
    table4 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: true)

    assert_kind_of Array,          table1.body
    assert_kind_of TableData::Row, table1.body.first

    assert_equal [%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], table1.body.map(&:to_a)
    assert_equal [%w[H1 H2 H3], [1,2,3]],               table2.body.map(&:to_a)
    assert_equal [[1,2,3], [:a, :b, :c]],               table3.body.map(&:to_a)
    assert_equal [[1,2,3]],                             table4.body.map(&:to_a)
  end

  test 'Table#<<' do
    table = TableData::Table.new(has_headers: false)

    assert_equal 0,  table.size
    assert_equal [], table.to_a

    table << [1,2,3]

    assert_equal 1,         table.size
    assert_equal [[1,2,3]], table.to_a

    table << [4,5,6]

    assert_equal 2, table.size
    assert_equal [[1,2,3], [4,5,6]], table.to_a

    table << table.row(0)

    assert_equal 3, table.size
    assert_equal [[1,2,3], [4,5,6], [1,2,3]], table.to_a
  end

  test 'Table#each' do
    table1 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: false)
    table2 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: true)
    table3 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: false)
    table4 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: true)

    result1 = []
    result2 = []
    result3 = []
    result4 = []

    table1.each do |row| result1 << row.to_a end
    table2.each do |row| result2 << row.to_a end
    table3.each do |row| result3 << row.to_a end
    table4.each do |row| result4 << row.to_a end

    assert_equal [%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], result1
    assert_equal [%w[H1 H2 H3], [1,2,3]],               result2
    assert_equal [[1,2,3], [:a, :b, :c]],               result3
    assert_equal [[1,2,3]],                             result4
  end

  test 'Table#each_row' do
    table1 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: false)
    table2 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: true)
    table3 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: false)
    table4 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: true)

    result1 = []
    result2 = []
    result3 = []
    result4 = []

    table1.each_row do |row| result1 << row.to_a end
    table2.each_row do |row| result2 << row.to_a end
    table3.each_row do |row| result3 << row.to_a end
    table4.each_row do |row| result4 << row.to_a end

    assert_equal [%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], result1
    assert_equal [%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], result2
    assert_equal [%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], result3
    assert_equal [%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], result4
  end

  test 'Table#each_column' do
    table1 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: false)
    table2 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: false, has_footer: true)
    table3 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: false)
    table4 = TableData.table_from_data([%w[H1 H2 H3], [1,2,3], [:a, :b, :c]], has_headers: true,  has_footer: true)

    result1 = []
    result2 = []
    result3 = []
    result4 = []

    table1.each_column do |column| result1 << column.to_a end
    table2.each_column do |column| result2 << column.to_a end
    table3.each_column do |column| result3 << column.to_a end
    table4.each_column do |column| result4 << column.to_a end

    assert_equal [['H1', 1, :a], ['H2', 2, :b], ['H3', 3, :c]], result1
    assert_equal [['H1', 1, :a], ['H2', 2, :b], ['H3', 3, :c]], result2
    assert_equal [['H1', 1, :a], ['H2', 2, :b], ['H3', 3, :c]], result3
    assert_equal [['H1', 1, :a], ['H2', 2, :b], ['H3', 3, :c]], result4
  end

  test 'Table#to_nested_array' do
    # TODO since the method might still change or even vanish
  end

  test 'Table#==' do
    # TODO since the method might still change
  end

  test 'Table#format' do
    # NOTE: We don't test the presenters themselves here
    table = TableData::Table.new

    table.format(:xls) # allow TableData to load the presenter
    assert_kind_of TableData::Presenters::Excel, table.format(:xls)
    table.format(:xlsx) # allow TableData to load the presenter
    assert_kind_of TableData::Presenters::Excel, table.format(:xlsx)
    table.format(:csv) # allow TableData to load the presenter
    assert_kind_of TableData::Presenters::CSV,   table.format(:csv)
    table.format(:pdf) # allow TableData to load the presenter
    assert_kind_of TableData::Presenters::PDF,   table.format(:pdf)
  end
end
