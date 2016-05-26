require 'jalalidate'
require 'telegram/bot'

class TelegramBot

  def initialize
    @@phones = $db.execute('select * from phones')
    last_sent= (IO.read("data/.last_sent_id") || '0' ).to_i
    @@ads = $db.execute('select * from ads where id> ? order by id ', last_sent)
    @@people = $db.execute('select * from people')
    @token = ENV['telegram_bot_token']
  end

  def send
    Telegram::Bot::Client.run(@token) do |bot|
      @@ads.each do |ad|
        message = build_message(ad)
        begin
          bot.api.send_message(chat_id: '@hamshahri_ads', text: message)
          sleep(rand(10))
        rescue
          IO.write("data/.last_sent_id", ad[0])
          exit
        end
      end
    end
    IO.write("data/.last_sent_id", @@ads.last[0])
  end

  def build_message(ad)
    ad_text = ad[2].gsub(/\d{8,11}/, '')
    #TODO: add date and area code to text
    <<-MSG
#{JalaliDate.new(Date.parse(ad[5])).strftime("#%A_%e_%b")}
#{ad_text}
##{ad[6].gsub('-', '_')}
#{@@people.select { |e| e[0] == ad[1] }.map { |e| e[1] }.first}
#{ad[2].scan(/\d{8,11}/).map { |e| e.length == 8 ? '021'+e : e }.join(' ')}
    MSG
  end
end