class ResultProcessor

  def initialize(results)
    @results= results
  end

  def write_results
    @results.each_key do |key|
      json_res= []
      @results[key].each do |item|
        json_res << process_item(item, key)
      end
      insert json_res
    end
  end

  def process_item(ad, key)
    result = Hash.new
    result['email'] = extract_email ad
    result['phones'] = extract_phones ad
    result['name'] = extract_name ad
    result['ad_text'] = ad[:ad_text]
    # result['ad_text_normalized'] = normalize ad[:ad_text]
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
      phones = ad[:contact].scan(/[0-9]{8,11}/)
      phones unless phones.empty?
    end
  end

  def extract_name(ad)
    if ad.key? :contact
      names = ad[:contact].scan(/\b\p{L}+\b/).join(' ')
      return names if !names.empty? and names.length>=3
    end
  end

  def insert json_results
    json_results.each do |res|
      person_id= res['phones'].map { |ph| $db.execute('select person_id from phones where no = ?', ph) }.flatten.first
      if person_id.nil?
        $db.execute('INSERT INTO people (name, email) values (? , ?);', res['name'], res['email'])
        person_id = $db.execute('SELECT last_insert_rowid() FROM people').first.first
      end
      res['phones'].each { |ph| $db.execute('INSERT OR IGNORE into phones(no, person_id) values (? , ?)', ph, person_id) }
      sql= <<-SQL
        insert or replace into
            ads(person_id, ad_text, counts, category, date)
            values (:pid , :ad, COALESCE((select counts from ads where person_id = :pid and ad_text= :ad),0) + 1, :cat, :date)
      SQL

      $db.execute(sql, pid: person_id, ad: res['ad_text'], cat: res['category'], date: Date.today)
    end
  end

  # def normalize
  #
  # end

end