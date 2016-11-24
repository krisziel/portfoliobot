require_relative 'stock'
require_relative 'portfolio'
require 'rest-client'
require 'yahoo-finance'
require 'sqlite3'

module PortfolioBot
  def self.format_currency number
    parts = number.to_s.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    amount = parts.join('.')
    formatted = ""
    if amount.to_f > 0
      formatted = "+$#{amount}"
    elsif amount.to_f < 0
      formatted = amount.insert(1, "$")
    else
      formatted = "$#{amount}"
    end
    return formatted
  end
  def self.color_range percent
    fibonacci = [1, 2, 3, 5, 8, 13, 21, 34, 55, 10946]
    colors = ["b0120a", "c41411", "d01716", "dd191d", "e51c23", "e84e40", "f36c60", "f69988", "f9bdbb", "fde0dc", "eeeeee", "d0f8ce", "a3e9a4", "72d572", "42bd41", "2baf2b", "259b24", "0a8f08", "0a7e07", "056f00", "0d5302"]
    color_index = 0
    negative = (percent < 0 ? -1 : 1)
    fibonacci.each_with_index do |number, index|
      if percent.abs < number
        color_index = (index + 1)
        break
      end
    end
    return colors[10 + (color_index * negative)]
  end
end
