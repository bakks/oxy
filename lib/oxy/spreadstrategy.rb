require_relative 'strategy'

class SpreadStrategy < Strategy
  @@interval          = 15
  @@takeRate          = 0.2
  @@takeIncrement     = 0.2
  @@levels            = 1
  @@defaultSize       = 0.1
  @@priceThreshold    = 0.005

  def initialize exchange
    super 'spreadstrat', exchange

    @log.info "interval        : #{@@interval}"
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

  def interval
    @@interval
  end

  def priceThreshold
    @@priceThreshold
  end

  def setOrders book
    fee = @exch.fee
    midpt = @exch.midpoint

    for i in 0..(@@levels - 1)
      halfSpreadPerc = fee * (1 + @@takeRate + @@takeIncrement * i)
      halfSpread = midpt * halfSpreadPerc
      bidPrice = midpt - halfSpread
      askPrice = midpt + halfSpread

      bid = Quote.new true, bidPrice, @@defaultSize
      ask = Quote.new false, askPrice, @@defaultSize

      book.add bid
      book.add ask
      @log.info "new order book level #{i} on midpt #{midpt} : bid #{bid.size} at #{bid.price}, ask #{ask.size} at #{ask.price}"
    end

    book
  end

end
