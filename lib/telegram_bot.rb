require 'jalalidate'
require 'telegram/bot'
require 'json'
require 'bitly'
require './lib/random_gaussian'
require './lib/elasticsearch_client'


class TelegramBot

  def initialize
    @randoms= RandomGaussian.new(5, 4)
    @people = $db.execute('select * from people')
    @token = ENV['telegram_bot_token']
    setup
  end

  def setup
    last_sent= (IO.read("data/.last_sent_id") || '0').to_i
    @ads = $db.execute('select * from ads where id>= ? order by id ', last_sent)
  end

  def send
    tries= tries||0
    ad1= nil
    setup
    Telegram::Bot::Client.run(@token) do |bot|
      @ads.each do |ad|
        ad1=ad
        message = build_message(ad)
        bot.api.send_message(chat_id: '@hamshahri_ads', text: message)
        rand = @randoms.rand
        puts "sleeping for #{rand} ..."
        sleep(rand.abs)
      end
    end
    IO.write("data/.last_sent_id", @ads.last[0]+1)
  rescue Exception => e
    puts e
    puts e.backtrace
    rand = @randoms.rand
    puts "sleeping longer for #{rand} ..."
    sleep(rand.abs)
    IO.write("data/.last_sent_id", ad1[0])
    tries +=1
    retry
  end

  def bitly_shorten_url
    Bitly.use_api_version_3
    Bitly.configure do |config|
      config.api_version = 3
      config.access_token = ENV['bitly_key']
    end
    today = Date.today.strftime("%Y-%m-%d")
    Bitly.client.shorten("http://adventures.gusto.ir/app/kibana#/discover?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:'#{today}T07:00:00.000Z',mode:absolute,to:'#{today}T23:00:00.000Z'))&_a=(columns:!(ad_text,category,counts,pdate,id,_score),index:ads,interval:h,query:(query_string:(analyze_wildcard:!t,query:'*')),sort:!(id,asc))")
  end

  def send_daily_digest
    search = $elasticsearch_client.search index: 'ads', body: {query: {match: {pdate: {query: JalaliDate.new(Date.today).strftime("%Y%n%d").to_i, type: "phrase"}}}}
    ads_count = search["hits"]["total"]
    ptoday= JalaliDate.new(Date.today).strftime("#%A_%e_%b")
    if(ads_count>0)
      short_url= bitly_shorten_url
      Telegram::Bot::Client.run(@token) do |bot|
        bot.api.send_message(chat_id: '@hamshahri_ads', text: """
لیست آگهی های #{ptoday}
#{short_url}
شامل #{ads_count} آگهی از زیر ۴۰ تا ۱۰۰ متر
""")
      end

    end
  end

  def build_message(ad)
    ad_text = ad[2].gsub(/\d{8,11}/, '')
    aread_codes= JSON.parse(IO.read(File.expand_path("../../data/area_codes.json", __FILE__)))
    phone = ad[2].scan(/(?<![\d])\d{8}(?![\d])/).first
    phone = phone || $db.execute('select no from phones where length(no)=8 and person_id = ?', ad[1]).first
    begin
      area=aread_codes.values.flatten.select { |e| e.values.flatten.include?(phone[0...4].to_i) }.first.keys.first
    rescue
    end if phone
    name = @people.select { |e| e[0] == ad[1] }.map { |e| e[1] }.first
    ptoday= JalaliDate.new(Date.parse(ad[4])).strftime("#%A_%e_%b")
    <<-MSG
#{ad[0]}
#{ptoday} #{"\nتعداد دفعات آگهی شدن: "+ ad[3].to_s if ad[3]>1}
#{ad_text}
##{ad[5].gsub('-', '_')} #{"\n" + name if name} #{"\n#" + area.gsub(' ', '_') if area}
#{ad[2].scan(/\d{8,11}/).map { |e| e.length == 8 ? '021'+e : e }.join(' ')}
    MSG
  end

end