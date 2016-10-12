require './lib/raw_ad_processor'
require 'open-uri'

class PlainScraper

  def initialize
    @results = {}
    @server = "http://www.rahnama.com/"
  end

  def start
    doc = Nokogiri::HTML(open(@server))
    href = doc.css("a[href*='فروش-املاك-مسكوني']").map { |e| e['href'] }.first
    home_doc= Nokogiri::HTML(open(URI.escape(href).to_s))
    links= IO.readlines('config/links.txt').map(&:chomp)
    links.each do |link|
      expected_count= home_doc.css("table a[href*='#{link.strip}'] small").first.text.scan(/\d+/).first.to_i
      scrap_pages(home_doc, link, expected_count)
    end
    @results
  end

  def scrap_pages home_doc, link, expected_count
    tries = 0
    first_page = home_doc.css("table a[href*='#{link}']").first()['href']
    doc= nil
    begin
      @results[link]= @results[link] || []
      page_count = (expected_count / 20.0).ceil
      first_page= first_page || link
      (1..page_count).each do |i|
        if i == 1
          npage_url = URI.unescape(first_page).gsub(link, "page/1/#{link}")
          doc= Nokogiri::HTML(open(URI.escape(npage_url).to_s))
        end
        @results[link] = @results[link] + extract_info(doc)
        npage_url = URI.unescape(first_page).gsub(link, "page/#{i+1}/#{link}")
        doc= Nokogiri::HTML(open(URI.escape(npage_url).to_s))
      end
      if (@results[link].length - expected_count).abs > 2
        puts "expected #{expected_count}: got #{@results[link].length }"
        raise StandardError.new "error in scraping ads"
      end
    end
  rescue StandardError => e
    puts e, e.backtrace
    if (tries <= 10)
      tries +=1
      @results[link]= []
      sleep 1
      retry
    else
      raise StandardError.new "error in scraping ads again"
    end
  end

  def extract_info doc

    doc.css('div.listing-summary1').map { |e|
      begin
        link_text = e.css('h3 a').first.text.gsub(/[\r\n\t]/, " ").gsub(/\s+/, " ").strip
        contact_elem = e.css('p span').first
      rescue Exception => f
        puts f.backtrace
        contact_elem = e.css('p')
      end
      ad_text_elem = e.css('p').first
      text = ad_text_elem.text.gsub(/[\r\n\t]/, " ").gsub(/\s+/, " ").strip
      text = link_text + ' '+ text unless (text.start_with? link_text)
      contact_text= contact_elem.text.gsub(/[\r\n\t]/, " ").gsub(/\s+/, " ").strip
      {contact: contact_text, ad_text: text}
    }
  end

end
