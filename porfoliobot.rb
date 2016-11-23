module PortfolioBot
  require 'rest-client'
  class Stock
    attr_reader :symbol, :share_data

    def initiate symbol
      @symbol = symbol
      get_share_data
    end
    def get_share_data
      url = "http://finance.yahoo.com/d/quotes.csv?s=#{symbol}&f=ncl1"
      csv_file = RestClient.get url
    end
  end

  class Porfolio
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
