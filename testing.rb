require_relative 'portfoliobot/portfoliobot'

stock = PortfolioBot::Stock.new 'LVS'
puts stock.inspect
stock = PortfolioBot::Stock.new 'AXP'
puts stock.inspect
stock = PortfolioBot::Stock.new 'AAPL'
puts stock.inspect
