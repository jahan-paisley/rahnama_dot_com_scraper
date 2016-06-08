require 'date'
require 'capybara/dsl'
require 'capybara/rspec'
require 'rspec/expectations'
require 'rspec/matchers'

require './lib/raw_ad_processor'

class Scrapper
  include RSpec::Matchers
  include Capybara::DSL

  def initialize
    @results = {}
  end

  def start
    visit('/')
    elem1 = first(:css, "a[href*='فروش-املاك-مسكوني']")
    window1= window_opened_by { elem1.click }
    links= IO.readlines('config/links.txt')
    links.each do |link|
      window2 = open_page(window1, link.strip)
      scrap_pages(window2, link)
    end
    @results
  end

  def scrap_pages(window2, link)
    within_window window2 do
      @results[link]= @results[link] || []
      page_all = page.all(:css, '#rahnama_content_c div.pager > ul li a')
      if (not page_all.empty?)
        page_count = page_all.last.text.to_i
        (1...page_count).each do |i|
          @results[link] = @results[link] + extract_info
          page.find(:css, '#rahnama_content_c div.pager > ul li a', :text => (i.to_i+1).to_s).click
        end
      end
      @results[link] = @results[link] + extract_info
    end
  end

  def extract_info
    find_all(:css, 'div.listing-summary1').map { |e|
      puts e.text
      begin
        e_find = e.find(:css, 'p span')
      rescue
        e_find = e.find(:css, 'p')
      end
      {contact: e_find.text, ad_text: e.find(:css, 'p', :match => :prefer_exact).text}
    }
  end

  def open_page(window1, search_element)
    window2= nil
    within_window window1 do
      elem2= find(:css, "table a[href*='#{search_element}']")
      window2= window_opened_by { elem2.click }
    end
    window2
  end

end