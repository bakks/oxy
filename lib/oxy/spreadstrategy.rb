require_relative 'strategy'

class SpreadStrategy < Strategy
  @@takeRate          = $config['spread_strategy']['take_rate']
  @@takeIncrement     = $config['spread_strategy']['take_increment']
  @@levels            = $config['spread_strategy']['levels']
  @@defaultSize       = $config['spread_strategy']['default_size']
  @@priceThreshold    = $config['spread_strategy']['price_threshold']

  def initialize exchange
    super 'spreadstrat', exchange

    @log.info "takeRate        : #{@@takeRate}"
    @log.info "takeIncrement   : #{@@takeIncrement}"
    @log.info "levels          : #{@@levels}"
    @log.info "defaultSize     : #{@@defaultSize}"
    @log.info "priceThreshold  : #{@@priceThreshold}"
    @log.info 'strategy initialized'
  end

  def takeRate
    @@takeRate
  end

  def priceThreshold
    @@priceThreshold
  end

  def defaultSize
    @@defaultSize
  end

  def setOrders book
    fee = @exch.fee
    midpt = @exch.midpoint
    bidSize = @@defaultSize
    askSize = @@defaultSize

    puts @exch.balance[:BTC].to_s + "   " + @exch.balance[:USD].to_s
    if @exch.balance[:BTC] > @exch.balance[:USD]
      askSize *= 2
    elsif @exch.balance[:BTC] < @exch.balance[:USD]
      bidSize *= 2
    end

    for i in 0..(@@levels - 1)
      halfSpreadPerc = fee * (1 + @@takeRate + @@takeIncrement * i)
      halfSpread = midpt * halfSpreadPerc
      bidPrice = midpt - halfSpread
      askPrice = midpt + halfSpread

      bid = Quote.new true, bidPrice, bidSize
      ask = Quote.new false, askPrice, askSize

      book.set bid
      book.set ask
      @log.info "new order book level #{i} on midpt #{midpt} : bid #{bid.size} at #{bid.price}, ask #{ask.size} at #{ask.price}"
    end

    book
  end

end
