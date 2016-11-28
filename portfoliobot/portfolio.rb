module PortfolioBot
  class Portfolio
    def initialize user
      @user = user
    end
    def positions
      positions = $db.execute("SELECT * FROM positions WHERE user=? ORDER BY symbol", [@user])
      if positions.count == 0
        positions = []
      end
      portfolio_stats = { cost: 0, value: 0, positions: positions.count }
      position_attachments = []
      positions.each do |position|
        position_data = build_position_attachment(position)
        portfolio_stats[:cost] += position_data[:stats][:cost]
        portfolio_stats[:value] += position_data[:stats][:value]
        position_attachments<<position_data[:attachment]
      end
      position_attachments.unshift(position_attachment portfolio_stats)
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
      current_value_text = "Value: *#{PortfolioBot.format_currency(current_value)} (#{PortfolioBot.format_currency(value_change, true)} // #{percent_change.round(2)}%)*"
      text = "#{cost_basis_text}\n#{current_value_text}"
      attachment = { fallback: text, color: color, text: text, mrkdwn_in: ["text"] }
    end
    def share_positions symbol
      positions = $db.execute("SELECT * FROM positions WHERE user=? AND symbol=?", [@user, symbol])
      if positions == 0
        return "no positions"
      else
        position_stats = { cost: 0, value: 0, positions: positions.count }
        position_attachments = []
        positions.each do |position|
          position_data = build_position_attachment(position)
          portfolio_stats[:cost] += position_data[:stats][:cost]
          portfolio_stats[:value] += position_data[:stats][:value]
          position_attachments<<position_data[:attachment]
        end
        position_attachments.unshift(position_attachment portfolio_stats)
      end
    end
    def add_position text
      position_matcher = /\$([a-zA-Z]{1,5}) ([0-9.]*)\@([\$0-9.]*)/
      position_data = text.match(position_matcher)
      stock = Stock.new position_data[1].upcase
      shares = position_data[2]
      price = position_data[3]
      if price <= 0
        return "Position's share price must be greater than $0.00"
      elsif shares <= 0
        return "Position's number of shares must be greater than 0"
      elsif stock.name == "N/A"
        return "#{stock.symbol} does not exist"
      else
        position_data = [symbol, price, shares, @user]
        $db.execute("INSERT INTO positions (symbol, price, shares, user) VALUES(?, ?, ?, ?)", position_data)
        return add_position_attachment(position_data)
      end
    end
    def build_position_attachment position
      symbol = position[0].upcase
      price = position[1].to_f
      shares = position[2].to_f
      stock = Stock.new symbol
      cost_basis = (shares * price)
      current_value = (shares * stock.share_data.last_trade_price.to_f)
      value_change = (current_value - cost_basis)
      percent_change = (value_change / cost_basis)*100
      color = PortfolioBot.color_range percent_change
      # title = "#{PortfolioBot.format_number(shares)} #{(shares == 1 ? 'share' : 'shares')} of #{symbol} purchased at $#{PortfolioBot.format_number(price)}"
      # cost_basis = "Cost basis: #{PortfolioBot.format_currency(cost_basis)}"
      cost_basis_text = "*#{symbol}* cost #{PortfolioBot.format_currency(cost_basis)} (#{PortfolioBot.format_number(shares)} #{(shares == 1 ? 'share' : 'shares')} at #{PortfolioBot.format_currency(price)})"
      current_value_text = "Value: *#{PortfolioBot.format_currency(current_value)} (#{PortfolioBot.format_currency(value_change, true)} // #{percent_change.round(2)}%)*"
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
  end
end
