require_relative 'portfoliobot/portfoliobot'
require 'slack-ruby-client'
require 'dotenv'
require 'sqlite3'
Dotenv.load
$db = SQLite3::Database.new "portfoliobot.db"

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::RealTime::Client.new
portfolios = {}

client.on :hello do
  $db.execute("CREATE TABLE IF NOT EXISTS positions (symbol varchar(5), price varchar(10), shares varchar(20), user varchar(20))")
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  puts portfolios.inspect
  user = data.user
  text = data.text
  next if client.self.id == user
  share_match = /\$([A-Za-z]{1,5})/
  position_match = /\$([a-zA-Z]{1,5}) ([0-9.]*)\@([\$0-9.]*)/
  portfolio_share_match = /^portfolio \$([A-Za-z]{1,5})/
  portfolio_match = /^portfolio/
  if text.match(position_match) || text.match(portfolio_match)
    if portfolios[user]
      portfolio = portfolios[user]
    else
      portfolio = PortfolioBot::Portfolio.new user
      portfolio[user] = portfolio
    end
    puts portfolio
  end
  case text
  when position_match then
    new_position = portfolio.add_position text
    client.web_client.chat_postMessage channel: data.channel, attachments: new_position, as_user: true
  when portfolio_share_match then
    symbol = text.match(portfolio_share_match)[1]
    share_positions = portfolio.share_positions symbol
    client.web_client.chat_postMessage channel: data.channel, attachments: share_positions, as_user: true
  when portfolio_match then
    positions = portfolio.positions
    client.web_client.chat_postMessage channel: data.channel, attachments: positions, as_user: true
  when share_match then
    symbol = text.match(share_match)[1]
    share_data = PortfolioBot::Stock.new symbol
    client.web_client.chat_postMessage channel: data.channel, attachments: share_data.attachments, as_user: true
  end
end

client.start!
