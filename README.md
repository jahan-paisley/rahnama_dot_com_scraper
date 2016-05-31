# http://rahnama.com scraper


A Simple Web Automation Script based on Capybara, RSpec and Thor.
---


### How to run:
  ```
  bundle install
  ```
#### Scrap Ads
  ```
  thor rahnama:scrap_ads
  ```
#### Send telegram messages
  ```
  export telegram_bot_token="Your Telegram Bot Token"
  thor rahnama:send
  ```

### Output
Output will be save in a sqlite database

### TODOS:
* Save the logo and the filename of bmp file in ads and associate them with advertisers
* Tokenize ads to extract important and mostly used keywords
