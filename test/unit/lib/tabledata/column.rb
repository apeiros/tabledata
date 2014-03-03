suite "TableData::Column" do
    test 'Column#table' do
        options = {data: [[1],[2],[3]], has_headers: false}
        table  = TableData::Table.new(options)
        column = TableData::Column.new(table, 0)

        assert_equal table.__id__, column.table.__id__
    end

    test 'Column#index' do
        options     = {data: [[1],[2],[3]], has_headers: false}
        table       = TableData::Table.new(options)
        column0     = TableData::Column.new(table, 0)
        column1     = TableData::Column.new(table, 1)
        column2     = TableData::Column.new(table, 2)
        #column42    = TableData::Column.new(table, 42) # This doesn't complain.

        assert_equal column0.index, 0
        assert_equal column1.index, 1
        assert_equal column2.index, 2
        #assert_equal_column42.index, 42 # This will probably change, I think.
    end

    test 'Column#header' do
        options_with_headers    = {data: [[:H1],[2],[3]], has_headers: true}
        options_no_headers      = {data: [[:H1],[2],[3]], has_headers: false}
        table_with_headers      = TableData::Table.new(options_with_headers)
        table_no_headers        = TableData::Table.new(options_no_headers)
        column_with_headers     = TableData::Column.new(table_with_headers, 0)
        column_no_headers       = TableData::Column.new(table_no_headers, 0)

        assert_equal column_with_headers.header, :H1
        assert_equal column_no_headers.header,   nil
    end

    test 'Column#accessor' do
    end

    test 'Column#[]' do
    end

    test 'Column#each' do
    end

    test 'Column#each_value' do
    end

    test 'Column#to_a' do
    end

    test 'Column#==' do
    end

    test 'Column#eql' do
    end

    test 'Column#hash' do
    end

end
