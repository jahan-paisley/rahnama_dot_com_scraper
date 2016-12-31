class RawAdProcessorForRental

  def initialize(results)
    @results= results
  end

  def persist_ads
    IO.write('./data/data-for-rental-'+JalaliDate.new(Date.today).strftime("%Y%n%d")+'.json', @results.to_json, mode:'a')
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
    ad[:ad_text]= ad[:ad_text].gsub(/[\r\n\t]/, " ").gsub(/\s+/, " ").strip
    newad= RawAdProcessor.remove_duplicate_leading(ad[:ad_text])
    ad[:ad_text]= newad
    result['ad_text'] = ad[:ad_text]
    result['category'] = key
    result
  end

  def self.remove_duplicate_leading ad_text
    (0..ad_text.length-1).reverse_each do |i|
      if(ad_text[i..-1].strip.start_with?(ad_text[0...i].strip) and i>5)
        return ad_text[i..-1].strip
      end
    end
    ad_text
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
      res['phones']= res['phones'] || []
      person_id= res['phones'].map { |ph| $db.execute('select person_id from phones where no = ?', ph) }.flatten.first
      if person_id.nil?
        $db.execute('INSERT INTO people (name, email) values (? , ?);', res['name'], res['email'])
        person_id = $db.execute('SELECT last_insert_rowid() FROM people').first.first
      end
      res['phones'].each { |ph| $db.execute('INSERT OR IGNORE into phones(no, person_id) values (? , ?)', ph, person_id) }
      sql= <<-SQL
        insert or replace into
            ads_for_rental(person_id, ad_text, counts, category, date)
            values (:pid , :ad, COALESCE((select counts from ads where person_id = :pid and ad_text= :ad),0) + 1, :cat, current_timestamp)
      SQL

      $db.execute(sql, pid: person_id, ad: res['ad_text'], cat: res['category'])
    end
  end

end