require 'capybara'
require 'selenium-webdriver'

class CapybaraConfig
  def self.init proxy=nil, browser= "chrome"
    Capybara.run_server = false
    Capybara.app_host = 'http://www.rahnama.com'
    Capybara.default_max_wait_time = 15

    if browser == "firefox"
      Capybara.register_driver :firefox do |app|
        profile = Selenium::WebDriver::Chrome::Profile.new
        # profile['javascript.enabled'] = false
        # profile['permissions.default.image'] = 2
        if proxy
          profile["network.proxy.type"] = 1
          profile["network.proxy.socks"] = proxy.split(':')[0]
          profile["network.proxy.socks_port"] = proxy.split(':')[1].to_i
          profile["network.proxy.socks_remote_dns"] = true
        end
        Capybara::Selenium::Driver.new(app, :browser => :firefox)
      end
      Capybara.default_driver = :firefox
    else
      Capybara.register_driver :chrome do |app|
        ENV['HTTP_PROXY'] = ENV['http_proxy'] = nil
        options = Hash.new.tap do |opt|
          opt[:browser] = :chrome
          opt[:proxy] = proxy if proxy
        end
        Capybara::Selenium::Driver.new(app, options)
      end
      Capybara.default_driver = :chrome
    end
  end
end

