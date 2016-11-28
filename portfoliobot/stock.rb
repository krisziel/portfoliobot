module PortfolioBot
  class Stock
    attr_reader :share_data

    def initialize symbol
      YahooFinance::Client.new.quotes([symbol.upcase], [:name, :symbol, :last_trade_price, :change, :change_in_percent]).each do |quote|
        @share_data = quote
      end
    end
    def attachments
      share_data = @share_data
      if share_data.name == "N/A"
        color = PortfolioBot.color_range share_data.change_in_percent.to_f
        change_text = "#{PortfolioBot.format_currency(share_data.change)} // #{share_data.change_in_percent}"
        text = "$#{share_data.last_trade_price} (#{change_text})"
        attachment = { fallback: "#{share_data.name} - #{text}", color: color, title: "<https://finance.yahoo.com/quote/#{share_data.symbol}|#{share_data.name} (#{share_data.symbol})>", text: text, mrkdwn: true }
      else
        attachment = { fallback: "#{share_data.symbol} is not a valid symbol.", text: "#{share_data.symbol} is not a valid symbol.", mrkdwn: true }
      end
      return [attachment]
    end
  end
end
