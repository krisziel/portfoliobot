module PortfolioBot
  class Stock
    attr_reader :symbol, :share_data

    def initialize symbol
      YahooFinance::Client.new.quotes([symbol], [:name, :symbol, :last_trade_price, :change, :change_in_percent]).each do |quote|
        @share_data = quote
      end
    end
    def attachments
      share_data = @share_data
      if share_data.change.to_f < 0
        color = "#dd4b39"
        value_change = share_data.change.insert(1, "$")
      else
        color = "#3d9400"
        value_change = "$#{share_data.change}"
      end
      change_text = "#{value_change} // #{share_data.change_in_percent}"
      text = "$#{share_data.last_trade_price} (#{change_text})"
      attachment = { fallback: share_data.name + " - " + text, color: color, title:"<https://finance.yahoo.com/quote/" + share_data.symbol + "|" + share_data.name + " (" + share_data.symbol + ")>", text: text, mrkdwn: true }
      return [attachment]
    end
  end
end
