#!/usr/bin/env ruby

require 'thor'
require './lib/capybara_config'
require './lib/scraper'
require './lib/plain_scraper'
require './lib/plain_scraper_for_rental'
require './lib/sqlite_config'
require './lib/telegram_bot'
require 'pry'
require 'json'

class Rahnama < Thor

  option :proxy
  option :browser
  desc 'scrap_ads', 'Scrap the Rahnama.com Real Estate Ads based on provided links.txt'
  def scrap_ads
    if options[:browser] == "plain"
      results= PlainScraper.new.start
    else
      CapybaraConfig.init options[:proxy], options[:browser]
      results= Scraper.new.start
    end
    processor = RawAdProcessor.new results
    processor.persist_ads
  end

  option :proxy
  option :browser
  desc 'scrap_rental_ads', 'Scrap the Rahnama.com Real Estate Ads based on provided links.txt'
  def scrap_rental_ads
    if options[:browser] == "plain"
      results= PlainScraperForRental.new.start
    else
      CapybaraConfig.init options[:proxy], options[:browser]
      results= Scraper.new.start
    end
    processor = RawAdProcessor.new results
    processor.persist_ads
  end

  desc 'send', 'Send ads to Telegram Channel'
  def send
    bot= TelegramBot.new
    bot.send
  end

  desc 'update_elasticsearch', 'Update Elasticsearch data'
  def update_elasticsearch
      ElasticsearchClient.import_ads
  end

  desc 'send_daily_digest', 'Send ads to Telegram Channel'
  def send_daily_digest
    bot= TelegramBot.new
    bot.send_daily_digest
  end

  desc 'generate_dic', 'Generaet Dictionary based on Ads words'
  def generate_dic
    rows= $db.execute('select * from ads')
    words= rows.map { |e| e[2] }.map { |e| e.split(/[\s,،]/).select { |e| e.length>1 } }.flatten
    counts = words.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
    IO.write('./data/words.json', JSON.pretty_generate(counts.sort_by { |_, v| v }))
  end
end

