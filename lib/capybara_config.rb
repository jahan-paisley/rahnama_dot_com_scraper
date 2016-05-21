require 'capybara'
require 'selenium-webdriver'

class CapybaraConfig
  def self.init
    Capybara.default_driver = :selenium_firefox_nojs
    Capybara.run_server = false
    Capybara.app_host = 'http://www.rahnama.com'

    Capybara.register_driver :selenium_firefox_nojs do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['javascript.enabled'] = false
      profile['permissions.default.image'] = '2'
      Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
    end
  end
end

CapybaraConfig.init