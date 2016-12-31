require 'sqlite3'

# Open a database
$db = SQLite3::Database.new 'data/people_ads.db'

# Create tables
$db.execute <<-SQL
  create table IF NOT EXISTS people
       (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name varchar(30),
        email varchar(30))
SQL

$db.execute <<-SQL
  create table IF NOT EXISTS ads
          (id INTEGER PRIMARY KEY AUTOINCREMENT,
           person_id integer,
           ad_text varchar(256),
           counts integer,
           date datetime DEFAULT current_timestamp,
           category varchar(256)
          );
SQL

$db.execute <<-SQL
  create table IF NOT EXISTS ads_for_rental
          (id INTEGER PRIMARY KEY AUTOINCREMENT,
           person_id integer,
           ad_text varchar(256),
           counts integer,
           date datetime DEFAULT current_timestamp,
           category varchar(256)
          );
SQL

$db.execute <<-SQL
  CREATE UNIQUE INDEX IF NOT EXISTS ADS_AD_TEXT_INDEX ON ads (ad_text);
SQL

$db.execute <<-SQL
  create table IF NOT EXISTS phones
          (no varchar(11) PRIMARY KEY,
           person_id integer)
SQL
