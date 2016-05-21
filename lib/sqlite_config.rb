require 'sqlite3'

# Open a database
$db = SQLite3::Database.new 'data/people_ads.db'

# Create a table
$db.execute <<-SQL
  create table IF NOT EXISTS people
       (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name varchar(30),
        email varchar(30))
SQL

$db.execute <<-SQL
  create table IF NOT EXISTS ads
          (id INTEGER PRIMARY KEY AUTOINCREMENT,
           people_id integer,
           ad_text varchar(256),
           ad_text_filtered varchar(256));
SQL

$db.execute <<-SQL
  CREATE UNIQUE INDEX IF NOT EXISTS ADS_AD_TEXT_INDEX ON ads (ad_text);
SQL

$db.execute <<-SQL
  create table IF NOT EXISTS phones
          (no varchar(11) PRIMARY KEY,
           people_id integer)
SQL

# Execute a few inserts
# {
#     'one' => 1,
#     'two' => 2,
# }.each do |pair|
#   $db.execute 'insert into numbers values ( ?, ? )', pair
# end

# Create another table with multiple columns

# $db.execute <<-SQL
#   create table students (
#     name varchar(50),
#     email varchar(50),
#     grade varchar(5),
#     blog varchar(50)
#   );
# SQL

# Execute inserts with parameter markers
# $db.execute('INSERT INTO students (name, email, grade, blog)
#             VALUES (?, ?, ?, ?)', ['Jane', 'me@janedoe.com', 'A', 'http://blog.janedoe.com'])
#
# Find a few rows
# $db.execute( 'select * from numbers' ) do |row|
#   p row
# end