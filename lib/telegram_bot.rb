class TelegramBot
  def initialize
    @token = ENV['telegram_bot_token']
    Telegram::Bot::Client.run(@token) do |bot|
      results = $db.execute('select * from ads')
      results.each do |ad|
        message = build_message(ad)
        bot.api.send_message(chat_id: '@hamshahri_ads', text: message)
        sleep(5)
      end
    end
  end

  def build_message(ad)
    phones = $db.execute('select * from phones')
    ad_text = ad[2].gsub(/\d{8,11}/, '')
    <<-MSG
#{ad_text}
##{ad[6].gsub('-', '_')}
#{phones.select { |e| e[1] == ad[1] }.map { |e| e[0].length==8 ? "021"+e[0] : e[0] }.join(" ")}
    MSG

  end
end
