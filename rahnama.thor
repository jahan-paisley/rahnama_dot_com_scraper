#!/usr/bin/env ruby

require 'thor'
require './lib/capybara_config'
require './lib/scrapper'
require './lib/sqlite_config'
require './lib/result_processor'
require './lib/telegram_bot'

class Rahnama < Thor
  desc 'scrap_ads', 'Scrap the Rahnama.com Real Estate Ads based on provided links.txt'
  def scrap_ads
    @results = []
    scrapper = Scrapper.new
    scrapper.start
  end

  desc 'send_telegram', 'Send ads to Telegram Channel'
  def send
    bot= TelegramBot.new
    bot.send
  end
end

