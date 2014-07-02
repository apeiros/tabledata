Users = Tabledata.define_table :user_table, "UserTable" do
  column_defaults strip: true

  string   :first_name, nil: true,  empty_string_is_nil: true, length: 2..30, pattern: /\A\p{Word}*\z/
  string   :last_name,  nil: true,  empty_string_is_nil: true, length: 2..30, pattern: /\A\p{Word}*\z/
  integer  :age,        nil: true,  between: 0..120
  date     :birthday,   nil: false, validate: ->(value) { value.between?(Date.today-365*120, Date.today+30*9) }
  datetime :created_at, nil: false
  boolean  :active,     nil: false, true_value: 'X', false_value: '', strip: true, present: ->(v) { v ? 'X' : '' }
  binary   :portrait,   nil: true,  adapt: ->(value) { Base64.decode64(value) }, present: ->(v) { Base64.strict_encode64(v) }

  validate_row do |row|
    row.errors.add :name unless row.first_name || row.last_name
  end
  validate_table do |table|
    table.errors.add :min_size, table.size unless table.size > 3
  end
end
#Addresses = Tabledata.define_table :user_table, "UserTable" do

UT = Users.from_file 'examples/normalized_import.csv'

__END__

# Transform an XLS to CSV
UserTable.from_file('users.xls').format(:csv).write('users.csv')
table = UserTable.from_file('users.xls')
table.valid?
table.errors
table.each do |body_row|
  body_row.valid?
  body_row.errors
  body_row.errors.each do |error|
    puts I18n.t error.id, scope: 'errors.tables.user_table', row: body_row.index, **error.values
  end
end

Tabledata.tables_from_file 'foo.xls', classes: [Users, Addresses] # match tables to sheets by sheet-name <-> .table_name
Tabledata.tables_from_file 'foo.xls', classes: {'users' => Users, 'addresses' => Addresses} # match tables to sheets by sheet-name <-> hash key
