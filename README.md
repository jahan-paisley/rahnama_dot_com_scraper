# http://rahnama.com scraper

A Simple Web Automation Script based on Capybara, Slenium, telegram-bot-ruby and Thor .
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
Output will be saved in a sqlite database and sent to this telegram channel: **https://telegram.me/hamshahri_ads**  

I've setup an ElasticSearch and Kibana to make it easier to search and visualize the data as it grows.

### TODOS:
* Save the logo and the filename of bmp file in ads and associate them with advertisers
* Tokenize ads to extract important and mostly used keywords
* Make the process scheduled and automatic using `whenever` gem
