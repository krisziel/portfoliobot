require_relative 'portfoliobot/portfoliobot'
require 'slack-ruby-client'
require 'dotenv'
Dotenv.load

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  attachment = {
    fallback: "Ticket #1943: Can't reset my password - https://groove.hq/path/to/ticket/1943",
    pretext: 'New ticket from Andrea Lee',
    title: "Ticket #1943: Can't reset my password",
    title_link: 'https://groove.hq/path/to/ticket/1943',
    text: 'Help! I tried to reset my password but nothing happened!',
    color: '#7CD197'
  }
  puts data
  case data.text
  when /\$[A-Za-z]{1,5}/ then
    symbol = data.text.match(/\$([A-Za-z]{1,5})/)[1]
    share_data = PorfolioBot::Stock.new symbol
    client.web_client.chat_postMessage channel: data.channel, attachments: share_data.attachments
  when /^portfolio/ then
    PortfolioBot::Portfolio.retrieve
    client.web_client.chat_postMessage channel: data.channel, text: "Sorry <@#{data.user}>, what?"
  end
end

client.start!
