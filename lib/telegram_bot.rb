class TelegramBot
  def initialize
    @token = ENV['telegram_bot_token']
    Telegram::Bot::Client.run(@token) do |bot|
      results = $db.execute('select * from ads')
      results.each do |ad|
        bot.api.send_message(chat_id: '@hamshahri_ads', text: ad[2])
      end
    end
  end
end
