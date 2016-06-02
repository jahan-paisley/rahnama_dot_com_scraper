require 'elasticsearch'
require 'sqlite3'


#Setup elasticsearch and feed it to make it available on Kibana for easy exploration
$db = SQLite3::Database.new 'data/people_ads.db'
columns, *rows = $db.execute2( "select * from ads" )
rows2= rows.map{|e| Hash[columns.zip e]}

client = Elasticsearch::Client.new log: true
rows2.each{|e| client.index(index: 'ads', type: 'ads', id:e["id"], body:e.merge({"date": Date.parse(e["timestamp"])}) )}



#Count words to build the dictionary and find the frequency of words in ads
words= rows.map{|e| e[2]}.map{|e| e.split(/[\s,،]/).select{|e| e.length>1}}.flatten;
counts = words.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
IO.write('./data/words.json', JSON.pretty_generate(counts.sort_by {|_key, value| value}))



