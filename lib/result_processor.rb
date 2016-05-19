class ResultProcessor
  def initialize results
    @results= results
    write_results
  end

  def write_results
    # filename = __dir__+ "/#{link}"+ Time.new.strftime("%F %T").gsub(':', '-') + '.txt'
    @results.each_key do |key|
      json_results= []
      @results[key].each do |item|
        json_results << process_item(item)
      end
      insert json_results
    end
  end

  def process_item ad
    result = Hash.new
    result['email'] = extract_email ad
    result['phones'] = extract_phones ad
    result['name'] = extract_name ad
    result['ad_text'] = ad[:ad_text]
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
      adcontact_scan = ad[:contact].scan(/[^0-9]/)
      adcontact_scan[0] unless adcontact_scan.empty?
    end
  end

  def insert json_results
    json_results.each do |res|
      people_id= res['phones'].map { |ph| $db.execute('select people_id from phones where no = ?', ph) }.flatten.first
      if people_id.nil?
        $db.execute("INSERT INTO people (name, email) values (? , ?);", res['name'], res['email'])
        people_id = $db.execute("SELECT last_insert_rowid() FROM people").first.first
      end
      res['phones'].each { |ph| $db.execute("INSERT OR IGNORE into phones(no, people_id) values (? , ?)", ph, people_id) }
      $db.execute("insert or ignore into ads(people_id, ad_text) values (? , ?)", people_id, res['ad_text'])
    end
  end

end