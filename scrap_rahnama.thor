#!/usr/bin/env ruby

require "thor"
require 'selenium-webdriver'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara-screenshot/capybara'
require "rspec/expectations"
require "rspec/matchers"
require 'date'

Capybara.register_driver :selenium_firefox_nojs do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["javascript.enabled"] = false
  profile["permissions.default.image"] = '2'
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
end

Capybara.default_driver = :selenium_firefox_nojs
Capybara.run_server = false
Capybara.app_host = 'http://www.rahnama.com'

class ScrapRahnama < Thor
  include RSpec::Matchers
  include Capybara::DSL

  desc "rahnama.com", "Run the Rahnama.com Task"

  def start
    @results = []
    visit('/')
    elem1 = first(:css, "a[href*='فروش-املاك-مسكوني']")
    window1= window_opened_by { elem1.click }
    links= IO.readlines('links.txt')
    links.each do |link|
      window2 = scrap_specific_page(window1, link.chomp)
      scrap_pages(window2)
      write_results link
    end
  end

  no_commands {
    def scrap_pages(window2)
      within_window window2 do
        page_count = page.all(:css, "#rahnama_content_c div.pager > ul li a").length
        (0...page_count).each do |i|
          find_all(:css, "div.listing-summary1").each { |e| @results << e.text.gsub(/\s+/, ' ') }
          page.find_all(:css, "#rahnama_content_c div.pager > ul li a").drop(i).first.click
        end
        find_all(:css, "div.listing-summary1").each { |e|
          @results << e.text.gsub(/\s+/, ' ')
        }
      end
    end
  }

  no_commands {
    def scrap_specific_page(window1, search_element)
      window2= nil
      within_window window1 do
        #expect(page).to have_css("a[href*='#{search_element}']")
        #binding.pry if search_element == nil or search_element == ''
        elem2= find(:css, "table a[href*='#{search_element}']")
        window2= window_opened_by { elem2.click }
      end
      window2
    end
  }

  no_commands {
    def write_results link
      filename = __dir__+ "/#{link}"+ Time.new.strftime("%F %T").gsub(':', '-') + '.txt'
      IO.write(filename, @results.join("\n"))
    end
  }
end

ScrapRahnama.start(ARGV)