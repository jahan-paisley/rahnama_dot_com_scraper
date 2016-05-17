class ResultProcessor
  def initialize links, results
    @links= links
    @results= results
  end

  def write_results link
    filename = __dir__+ "/#{link}"+ Time.new.strftime("%F %T").gsub(':', '-') + '.txt'
    json_results= []
    @results.each do |item|
      json_results << process_item(item)
    end
    IO.write(filename, json_results.join("\n"))
    insert json_results
  end

  def process_item ad
    result = Hash.new
    result['email'] = extract_email ad
    result['phones'] = extract_phones ad
    result['name'] = extract_name ad
    result['ad_text'] = ad
    result
  end

  def extract_email(ad)
    ad['contact'].scan(/\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/)
  end

  def extract_phones(ad)
    ad['contact'].scan(/[0-9]{8,11}/)
  end

  def extract_name(ad)
    ad['contact'].scan(/[^0-9]/)
  end

  def insert json_results
    json_results.each do |res|
      people_id= res['phone'].map { |ph| db.execute('select people_id from phones where no = ?', ph) }
      unless people_id
        people_id = db.execute("INSERT INTO people (name, email) values (? , ?)", res['name'], res['email'])
      end
      res['phones'].each { |ph| db.execute("INSERT INTO phones(no, people_id) values (? , ?)", ph, people_id) }
      db.execute("insert into ads(people_id, ad_text) values (? , ?)", people_id, res['ad_text'])
    end
  end

end