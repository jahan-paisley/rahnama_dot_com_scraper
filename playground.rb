require 'elasticsearch'
require 'sqlite3'
require 'jalalidate'

$db = SQLite3::Database.new 'data/people_ads.db'
columns, *rows = $db.execute2("select * from ads");
rows2= rows.map { |e| Hash[columns.zip e] };

def build_new_hash e
  converted_map = e.map do |k, v|
    [k, if k == 'date' then
          Date.parse(e['date'])
        else
          v.respond_to?(:chomp) ? v.chomp : v
        end]
  end.flatten
  added_pdate = Hash[*converted_map]
  added_pdate.merge({pdate: JalaliDate.new(Date.parse(e['date'])).strftime("%Y%m%d").to_i})
end

#Setup elasticsearch and feed it to make it available on Kibana for easy exploration
client = Elasticsearch::Client.new(log: true);
rows2.each do |e|
  client.index(index: 'ads', type: 'ads', id: e["id"], body: build_new_hash(e))
end


#Count words to build the dictionary and find the frequency of words in ads
words= rows.map { |e| e[2] }.map { |e| e.split(/[\s,،]/).select { |e| e.length>1 } }.flatten;
counts = words.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
IO.write('./data/words.json', JSON.pretty_generate(counts.sort_by { |_key, value| value }))


#elasticsearch query
query ={
    "query": {
        "bool": {
            "must":     { "match": { "ad_text": "نوساز" }},
            "should": [
                { "match": { "ad_text": "لازم" }},
                { "match": { "ad_text": "فول" }},
                { "match": { "ad_text": "زیرقیمت"   }}
            ]
        }
    }
}