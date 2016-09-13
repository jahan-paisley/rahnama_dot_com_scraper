require 'date'
require 'capybara/dsl'
require 'capybara/rspec'
require 'rspec/expectations'
require 'rspec/matchers'

require './lib/raw_ad_processor'
require 'pry'

class Scraper
  include RSpec::Matchers
  include Capybara::DSL

  def initialize
    @results = {}
  end

  def start
    visit('/')
    elem1 = first(:css, "a[href*='فروش-املاك-مسكوني']")
    window1= window_opened_by { elem1.click }
    links= IO.readlines('config/links.txt').map(&:chomp)
    links.each do |link|
      expected_count=0
      within_window(window1) { expected_count= find(:css, "table a[href*='#{link.strip}'] small").text.scan(/\d+/).first.to_i }
      window2 = open_page(window1, link.strip)
      scrap_pages(window2, link, expected_count)
    end
    @results
  end

  def scrap_pages(window2, link, expected_count)
    tries = 0
    first_page= nil
    begin
      within_window window2 do
        @results[link]= @results[link] || []
        page_count = (expected_count / 20.0).ceil
        first_page= first_page || current_url
        (1..page_count).each do |i|
          if i == 1
            url_gsub = URI.unescape(first_page).gsub(link, "page/1/#{link}")
            visit(URI.escape(url_gsub))
          end
          @results[link] = @results[link] + extract_info
          url_gsub = URI.unescape(first_page).gsub(link, "page/#{i+1}/#{link}")
          visit(URI.escape(url_gsub))
        end
        if (@results[link].length - expected_count).abs > 1
          puts "expected #{expected_count}: got #{@results[link].length }"
          raise StandardError.new "error in scraping ads"
        end
      end
    rescue StandardError => e
      puts e
      puts e.backtrace
      if (tries <= 10)
        tries +=1
        @results[link]= []
        sleep 1
        retry
      else
        raise StandardError.new "error in scraping ads again"
      end
    ensure
      window2.close
    end

  end

  def extract_info
    find_all(:css, 'div.listing-summary1').map { |e|
      begin
        link_text = e.find(:css, 'h3 a').text
        contact_elem = e.find(:css, 'p span')
      rescue Exception => f
        puts f.backtrace
        contact_elem = e.find(:css, 'p')
      end
      text = e.find(:css, 'p', :match => :prefer_exact).text
      text = link_text + ' '+ text unless (text.start_with? link_text)
      {contact: contact_elem.text, ad_text: text}
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
