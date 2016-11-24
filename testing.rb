# require_relative 'portfoliobot/portfoliobot'
#
# stock = PortfolioBot::Stock.new 'LVS'
# puts stock.inspect
# stock = PortfolioBot::Stock.new 'AXP'
# puts stock.inspect
# stock = PortfolioBot::Stock.new 'AAPL'
# puts stock.inspect
require 'sqlite3'

db = SQLite3::Database.new "test.db"

# rows = db.execute <<-SQL
#   CREATE TABLE IF NOT EXISTS positions (
#     symbol varchar(5),
#     price varchar(10),
#     shares varchar(20),
#     user varchar(20)
#   );
# SQL
db.execute("CREATE TABLE IF NOT EXISTS positions (symbol varchar(5), price varchar(10), shares varchar(20), user varchar(20))")

db.execute("INSERT INTO positions (symbol, price, shares, user) VALUES(?, ?, ?, ?)", ["LVS", "1.42", "25", "U33PKK7HV"])
