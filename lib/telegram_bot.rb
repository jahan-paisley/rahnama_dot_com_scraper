require 'jalalidate'
require 'telegram/bot'
require './lib/random_gaussian'
require 'json'

class TelegramBot

  def initialize
    @randoms= RandomGaussian.new(5, 4)
    @@phones = $db.execute('select * from phones')
    @@people = $db.execute('select * from people')
    @token = ENV['telegram_bot_token']
    setup
  end

  def setup
    last_sent= (IO.read("data/.last_sent_id") || '0').to_i
    @@ads = $db.execute('select * from ads where id>= ? order by id ', last_sent)
  end

  def send
    tries= tries||0
    ad1= nil
    setup
    Telegram::Bot::Client.run(@token) do |bot|
      @@ads.each do |ad|
        ad1=ad
        message = build_message(ad)
        bot.api.send_message(chat_id: '@hamshahri_ads', text: message)

        rand = @randoms.rand
        puts "sleeping for #{rand} ..."
        sleep(rand.abs)
      end
    end
    IO.write("data/.last_sent_id", @@ads.last[0]+1)
  rescue Exception => e
    puts e
    rand = @randoms.rand
    puts "sleeping longer for #{rand} ..."
    sleep(rand.abs)
    IO.write("data/.last_sent_id", ad1[0])
    tries +=1
    retry
  end

  def build_message(ad)
    ad_text = ad[2].gsub(/\d{8,11}/, '')
    aread_codes= JSON.parse(IO.read(File.expand_path("../../data/area_codes.json", __FILE__)))
    phone = ad[2].scan(/(?<![\d])\d{8}(?![\d])/).first
    begin
      area=aread_codes.values.flatten.select { |e| e.values.flatten.include?(phone[0...4].to_i) }.first.keys.first
    rescue
    end if phone
    name = @@people.select { |e| e[0] == ad[1] }.map { |e| e[1] }.first
    <<-MSG
#{ad[0]}
#{JalaliDate.new(Date.parse(ad[5])).strftime("#%A_%e_%b")} #{"\nتعداد دفعات آگهی شدن: "+ ad[4].to_s if ad[4]>1}
#{ad_text}
##{ad[6].gsub('-', '_')} #{"\n" + name if name} #{"\n#" + area.gsub(' ', '_') if area}
#{ad[2].scan(/\d{8,11}/).map { |e| e.length == 8 ? '021'+e : e }.join(' ')}
MSG
  end

end