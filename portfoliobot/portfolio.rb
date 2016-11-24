module PortfolioBot
  class Portfolio
    def initialize user
      self.user = user
    end
    def positions
      positions = $db.execute("SELECT * FROM positions WHERE user=?", [user])
      if positions.count == 0
        positions = []
      end
    end
    def share_positions symbol
    end
    def add_position text
      position_matcher = /\$([a-zA-Z]{1,5}) ([0-9.]*)\@([\$0-9.]*)/
      position_data = text.match(position_matcher)
      symbol = position_data[1]
      shares = position_data[2]
      price = position_data[3]
      position_data = [symbol, price, shares, user]
      db.execute("INSERT INTO positions (symbol, price, shares, user) VALUES(?, ?, ?, ?)", position_data)
    end
    def attachments
    end
    def build_position_attachment position
      symbol = position[0]
      shares = position[1]
      price = position[2]
      stock = Stock.new symbol
      cost_basis = (shares.to_f * price.to_f)
      current_value = (shares.to_f * stock.last_trade_price)
      value_change = (current_value - cost_basis)
      percent_change = (value_change / costs_basis)
      color = PortfolioBot.color_range percent_change
      cost_basis = "Cost basis: $#{cost_basis}"
      current_value = "Current value: $#{current_value} ()"
    end
    def add_position_attachment data
      symbol = position[0]
      shares = position[1]
      price = position[2]
      cost_basis = (shares.to_f * price.to_f)
      text = "You added #{shares} #{(shares == 1 ? 'share' : 'shares')} of #{symbol} with cost basis of #{PortfolioBot.format_currency(cost_basis)}"
    end
  end
end


# var shareCount = "You added " + args.shares + " " + (args.shares === 1 ? "share" : "shares") + " of " + args.symbol;
# var percentChange = (percentChange >= 0 ? "-" : "+") + percentChange + "%"
# var costBasis = "Cost basis is $" + basis + ", current value is " + value + " (" + percentChange + ")";
# var fallback = company + " - " + shareCount + " - " + costBasis;
# var title = "<https://finance.yahoo.com/quote/" + symbol + "|" + stock.company + " (" + symbol + ")>";
# var text = shareCount + "\n" + costBasis;
# var color = (value > basis) ? "#3d9400" : "#dd4b39";
# var message = { attachments: JSON.stringify([{ fallback:fallback, color:color, title:title, text:text, mrkdwn:true }]) }
# self.postMessageToChannel(args.channel.name, "", message);
# };
#
# StocksBot.prototype._replyWithPortfolio = function (originalMessage) {
# var self = this;
#
# };
#
# StocksBot.prototype._getStockPrice = function (symbol, callback, args) {
# var self = this;
# var url = 'http://finance.yahoo.com/d/quotes.csv?s=' + symbol + '&f=ncl1'
# request(url, function(err, res, body){
#   if(err) {
#     return null;
#   } else {
#     var symbolRegexp = /\"([\w \,\.]*)\",\"([0-9\+\-\. \%]*)\"\,([\d\.]*)/;
#     var shareData = symbolRegexp.exec(body);
#     if(!shareData) {
#       return null;
#     }
#     var company = shareData[1];
#     var change = shareData[2].replace(/^\+/, "+$").replace(/^\-/, "-$").replace(" - ", " / ");
#     var current = shareData[3];
#     var stock = { company:company, change:change, current:current };
#     callback(args);
#   }
# });
