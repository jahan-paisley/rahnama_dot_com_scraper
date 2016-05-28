require 'capybara'
require 'selenium-webdriver'

class CapybaraConfig
  def self.init proxy=nil
    Capybara.default_driver = :selenium_firefox_nojs
    Capybara.run_server = false
    Capybara.app_host = 'http://www.rahnama.com'

    Capybara.register_driver :selenium_firefox_nojs do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['javascript.enabled'] = false
      profile['permissions.default.image'] = '2'
      if proxy
        profile["network.proxy.type"] = 1
        profile["network.proxy.socks"] = proxy.split(':')[0]
        profile["network.proxy.socks_port"] = proxy.split(':')[1].to_i
        profile["network.proxy.socks_remote_dns"] = true
      end
      Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
    end
  end
end

