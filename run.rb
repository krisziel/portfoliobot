require_relative 'portfoliobot/portfoliobot'
require 'slack-ruby-client'
require 'dotenv'
Dotenv.load

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::RealTime::Client.new
portfolios = {}

client.on :message do |data|
  puts data.inspect
  share_match = /\$([A-Za-z]{1,5})/
  position_match = /\$([a-zA-Z]{1,5}) ([0-9.]*)\@([\$0-9.]*)/
  portfolio_share_match = /^portfolio \$([A-Za-z]{1,5})/
  case data.text
  when position_match then
    PortfolioBot::Portfolio.add_position data.text
    # client.web_client.chat_postMessage channel: data.channel, text: data.text, as_user: true
  when portfolio_share_match then
    symbol = data.text.match(portfolio_share_match)[1]
    PortfolioBot::Portfolio.retrieve_share data.user, symbol
    # client.web_client.chat_postMessage channel: data.channel, text: "Sorry <@#{data.user}>, what?", as_user: true
  when /^portfolio/ then
    PortfolioBot::Portfolio.retrieve data.user
    # client.web_client.chat_postMessage channel: data.channel, text: "Sorry <@#{data.user}>, what?", as_user: true
  when share_match then
    symbol = data.text.match(share_match)[1]
    share_data = PortfolioBot::Stock.new symbol
    client.web_client.chat_postMessage channel: data.channel, attachments: share_data.attachments, as_user: true
  end
end

client.start!
