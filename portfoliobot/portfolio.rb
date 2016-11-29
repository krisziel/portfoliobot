module PortfolioBot
  class Portfolio
    def initialize user
      @user = user
    end
    def positions
      positions = $db.execute("SELECT * FROM positions WHERE user=?", [@user])
      if positions.count == 0
        return [{ pretext: "You haven't added any positions. To add some, message me *$[symbol] [sharecount]@[price]*.", mrkdwn_in: ["pretext"] }]
      end
      symbols = {}
      positions.each do |position|
        if symbols[position[0]]
          symbols[position[0]][:positions]<<position
        else
          symbols[position[0]] = { quote: nil, positions: [position] }
        end
      end
      portfolio_stats = { cost: 0, value: 0 }
      portfolio = get_stock_prices symbols
      position_attachments = []
      portfolio.values.each do |symbol|
        symbol_data = { shares: 0, cost: 0, positions: 0, quote: symbol[:quote] }
        symbol_data[:positions] = symbol[:positions].count
        symbol[:positions].each do |position|
          price = position[1].to_f
          shares = position[2].to_f
          symbol_data[:shares] += shares
          symbol_data[:cost] += (shares * price)
        end
        position_data = build_position_attachment symbol_data
        portfolio_stats[:cost] += position_data[:stats][:cost]
        portfolio_stats[:value] += position_data[:stats][:value]
        position_attachments<<position_data[:attachment]
      end
      portfolio_stats[:positions] = positions.count
      position_attachments.unshift(position_attachment portfolio_stats)
      position_attachments<<{ pretext: "message *[symbol] positions* for a list of all your positions in a certain stock", mrkdwn_in: ["pretext"] }
      return position_attachments
    end
    def position_attachment stats, symbol = false
      current_value = stats[:value]
      cost_basis = stats[:cost]
      positions = stats[:positions]
      value_change = (current_value - cost_basis)
      percent_change = (value_change / cost_basis)*100
      color = PortfolioBot.color_range percent_change
      if symbol
        cost_basis_text = "#{positions} #{(positions == 1 ? 'position' : 'positions')} in #{symbol} with cost basis of #{PortfolioBot.format_currency(cost_basis)}"
      else
        cost_basis_text = "#{positions} #{(positions == 1 ? 'position' : 'positions')} with cost basis of #{PortfolioBot.format_currency(cost_basis)}"
      end
      current_value_text = "Value: *#{PortfolioBot.format_currency(current_value)} (#{PortfolioBot.format_currency(value_change, true)} // #{PortfolioBot.format_number(percent_change)}%)*"
      text = "#{cost_basis_text}\n#{current_value_text}"
      attachment = { fallback: text, color: color, text: text, mrkdwn_in: ["text"] }
    end
    def share_positions symbol
      positions = $db.execute("SELECT * FROM positions WHERE user=? AND symbol LIKE ?", [@user, symbol])
      if positions.count == 0
        return [{ pretext:"You have no positions in *#{symbol}*. To add some, message me *#{symbol} [share count]@[price]*", mrkdwn_in: ["pretext"] }]
      else
        portfolio_stats = { cost: 0, value: 0 }
        quote = get_share_quote symbol
        position_attachments = []
        positions.each do |position|
          price = position[1].to_f
          shares = position[2].to_f
          position_data = { shares: shares, symbol: symbol, cost: (shares * price), quote: quote, positions: 1 }
          position_attachment = build_position_attachment position_data
          position_attachments<<position_attachment[:attachment]
          portfolio_stats[:cost] += position_attachment[:stats][:cost]
          portfolio_stats[:value] += position_attachment[:stats][:value]
        end
        portfolio_stats[:positions] = positions.count
        position_attachments.unshift(position_attachment(portfolio_stats, symbol))
      end
      return position_attachments
    end
    def add_position text
      position_matcher = /\$([a-zA-Z]{1,5}) ([0-9.]*)\@([\$0-9.]*)/
      position_data = text.match(position_matcher)
      stock = Stock.new position_data[1]
      shares = position_data[2]
      price = position_data[3]
      if price.to_f <= 0
        return "Position's share price must be greater than $0.00"
      elsif shares.to_f <= 0
        return "Position's number of shares must be greater than 0"
      elsif stock.share_data.name == "N/A"
        return "#{stock.symbol} does not exist"
      else
        position_data = [stock.share_data.symbol, price, shares, @user]
        $db.execute("INSERT INTO positions (symbol, price, shares, user) VALUES(?, ?, ?, ?)", position_data)
        return add_position_attachment(position_data)
      end
    end
    def build_position_attachment position
      position_count = position[:positions]
      quote = position[:quote]
      symbol = quote.symbol
      shares = position[:shares]
      cost_basis = position[:cost]
      price = (cost_basis / shares)
      current_value = (shares * quote.last_trade_price.to_f)
      value_change = (current_value - cost_basis)
      percent_change = (value_change / cost_basis)*100
      color = PortfolioBot.color_range percent_change
      if position_count == 1
        cost_basis_text = "*#{symbol}* cost #{PortfolioBot.format_currency(cost_basis)} (#{PortfolioBot.format_number(shares)} #{(shares == 1 ? 'share' : 'shares')} at #{PortfolioBot.format_currency(price)})"
      else
        cost_basis_text = "#{position_count} positions in *#{symbol}* cost #{PortfolioBot.format_currency(cost_basis)} (#{PortfolioBot.format_number(shares)} #{(shares == 1 ? 'share' : 'shares')} at average price of #{PortfolioBot.format_currency(price)})"
      end
      current_value_text = "Value: *#{PortfolioBot.format_currency(current_value)} (#{PortfolioBot.format_currency(value_change, true)} // #{PortfolioBot.format_number(percent_change)}%)*"
      text = "#{cost_basis_text}\n#{current_value_text}"
      attachment = { fallback: "#{symbol} - #{text}", color: color, text: text, mrkdwn_in: ["text"] }
      position_stats = { cost: cost_basis, value: current_value }
      return { attachment: attachment, stats: position_stats }
    end
    def add_position_attachment data
      symbol = data[0]
      price = data[1]
      shares = data[2]
      cost_basis = (shares.to_f * price.to_f)
      text = "You added #{PortfolioBot.format_number(shares)} #{(shares == 1 ? 'share' : 'shares')} of #{symbol} at #{PortfolioBot.format_currency(price)} (cost basis of #{PortfolioBot.format_currency(cost_basis)})"
      return text
    end
    def get_share_quote symbol
      YahooFinance::Client.new.quotes([symbol], [:name, :symbol, :last_trade_price]).each do |quote|
        return quote
      end
    end
    def get_stock_prices symbols
      YahooFinance::Client.new.quotes(symbols.keys, [:name, :symbol, :last_trade_price]).each do |quote|
        symbols[quote.symbol][:quote] = quote
      end
      return symbols
    end
  end
end
