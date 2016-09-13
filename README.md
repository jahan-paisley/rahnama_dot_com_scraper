# rahnama.com scraper 

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

I've setup an ElasticSearch and [Kibana](http://adventures.gusto.ir/app/kibana#/discover?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:now-30d,mode:quick,to:now))&_a=(columns:!(ad_text,category,counts,pdate,id,_score),index:ads,interval:h,query:(query_string:(analyze_wildcard:!t,query:'*')),sort:!(id,asc))) to make it easier to search and visualize the data as it grows.


### TODOS:
* Save the logo and the filename of bmp file in ads and associate them with advertisers
* Tokenize ads to extract important and mostly used keywords
* Make the process scheduled and automatic using `whenever` gem
