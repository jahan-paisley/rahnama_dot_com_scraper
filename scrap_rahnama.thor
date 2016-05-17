#!/usr/bin/env ruby

require "thor"
require "./lib/scrapper"
require "./lib/capybara_config"
require "./lib/sqlite_config"

class ScrapRahnama < Thor
  desc "rahnama.com", "Run the Rahnama.com Task"
  def start
    @results = []
    processor = Scrapper.new
    processor.start
  end
end

ScrapRahnama.start(ARGV)