#!/usr/bin/env ruby

require 'thor'
require './lib/capybara_config'
require './lib/scrapper'
require './lib/sqlite_config'
require './lib/telegram_bot'
require 'pry'
require 'json'

class Rahnama < Thor

  desc 'scrap_ads', 'Scrap the Rahnama.com Real Estate Ads based on provided links.txt'
  option :proxy
  option :browser

  def scrap_ads
    CapybaraConfig.init options[:proxy], options[:browser]
    results= Scrapper.new.start
    processor = RawAdProcessor.new results
    processor.persist_ads
  end

  desc 'send_telegram', 'Send ads to Telegram Channel'

  def send
    bot= TelegramBot.new
    bot.send
  end

  desc 'gen_dic', 'Generaet Dictionary based on Ads words'

  def generate_dic
    rows= $db.execute('select * from ads')
    words= rows.map { |e| e[2] }.map { |e| e.split(/[\s,،]/).select { |e| e.length>1 } }.flatten
    counts = words.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
    IO.write('./data/words.json', JSON.pretty_generate(counts.sort_by { |_, v| v }))
  end
end

