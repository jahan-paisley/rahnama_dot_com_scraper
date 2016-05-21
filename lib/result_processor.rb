class ResultProcessor
  def initialize results
    @results= results
    write_results
  end

  def write_results
    # filename = __dir__+ '/#{link}'+ Time.new.strftime('%F %T').gsub(':', '-') + '.txt'
    @results.each_key do |key|
      json_results= []
      @results[key].each do |item|
        json_results << process_item(item, key)
      end
      insert json_results
    end
  end

  def process_item ad, key
    result = Hash.new
    result['email'] = extract_email ad
    result['phones'] = extract_phones ad
    result['name'] = extract_name ad
    result['ad_text'] = ad[:ad_text]
    result['category'] = key
    result
  end

  def extract_email(ad)
    if ad.key? :contact
      adcontact_scan = ad[:contact].scan(/\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/)
      adcontact_scan[0] unless adcontact_scan.empty?
    end
  end

  def extract_phones(ad)
    if ad.key? :contact
      adcontact_scan = ad[:contact].scan(/[0-9]{8,11}/)
      adcontact_scan unless adcontact_scan.empty?
    end
  end

  def extract_name(ad)
    if ad.key? :contact
      adcontact_scan = ad[:contact].scan(/\b\p{L}+\b/)
      adcontact_scan_join = adcontact_scan.join(' ')
      if !adcontact_scan.empty? and adcontact_scan_join.length>=3 and adcontact_scan_join
        return adcontact_scan_join
      end
    end
  end

  def insert json_results
    json_results.each do |res|
      people_id= res['phones'].map { |ph| $db.execute('select people_id from phones where no = ?', ph) }.flatten.first
      if people_id.nil?
        $db.execute('INSERT INTO people (name, email) values (? , ?);', res['name'], res['email'])
        people_id = $db.execute('SELECT last_insert_rowid() FROM people').first.first
      end
      res['phones'].each { |ph| $db.execute('INSERT OR IGNORE into phones(no, people_id) values (? , ?)', ph, people_id) }
      sql= <<-SQL
        insert or replace into
            ads(people_id, ad_text, counts, category)
            values (:pid , :ad, COALESCE((select counts from ads where people_id = :pid and ad_text= :ad),0) + 1, :cat)
      SQL

      $db.execute(sql, 'pid' => people_id, 'ad' => res['ad_text'], 'cat' => res['category'])
    end
  end

end