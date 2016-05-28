#!/usr/bin/env ruby

require 'thor'
require './lib/capybara_config'
require './lib/scrapper'
require './lib/sqlite_config'
require './lib/telegram_bot'
require 'pry'

class Rahnama < Thor
  desc 'scrap_ads', 'Scrap the Rahnama.com Real Estate Ads based on provided links.txt'
  option :proxy
  def scrap_ads
    CapybaraConfig.init options[:proxy]
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

