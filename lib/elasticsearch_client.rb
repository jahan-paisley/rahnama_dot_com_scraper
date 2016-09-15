require 'elasticsearch'
require 'jalalidate'
require './lib/sqlite_config'

$elasticsearch_client = Elasticsearch::Client.new()

class ElasticsearchClient

  def self.import_ads
    columns, *rows = $db.execute2("select * from ads where id > ?", (IO.read("data/.last_exported_id") || '0').to_i)
    prows= rows.map { |e| Hash[columns.zip e] }
    # (1..13000).each{|e| begin client.delete(index: 'ads', type:'ads', id: e) rescue puts ' '; end}
    prows.each do |row|
      $elasticsearch_client.index(index: 'ads', type: 'ads', id: row["id"], body: build_ui_friendly_hash(row));
    end;

    IO.write("data/.last_exported_id", prows.sort_by { |e| e['id'] }.last['id'])
  end

  private
  def self.build_ui_friendly_hash row
    converted_map = row.map do |k, v|
      [k, if k == 'date' then
            Date.parse(row['date'])
          else
            v.respond_to?(:chomp) ? v.chomp : v
          end]
    end.flatten
    added_pdate = Hash[*converted_map]
    pdate = JalaliDate.new(Date.parse(row['date'])).strftime("%Y%n%d").to_i
    added_pdate.merge({pdate: pdate})
  end

end