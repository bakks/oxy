class Strategy
  @@log               = Log.new 'strategy'
  @@takeRate          = 0.2
  @@takeIncrement     = 0.2
  @@levels            = 1
  @@defaultSize       = 0.1
  @@priceThreshold    = 0.005

  attr_reader :takeRate, :takeIncrement, :levels, :defaultSize, :priceThreshold

  def initialize exchange
    @exch = exchange
  end

  def run
  end

  def iteration
    @exch.fetchDepth

    fee = @exch.fee
    midpt = @exch.midpoint

    @@log.error "bad fee: #{fee}" if !fee or fee < 0 or fee > 0.006
    @@log.error "bad midpt: #{midpt}" if !midpt or midpt < 4 or midpt > 20

    book = Book.new

    for i in 0..(@@levels - 1)
      halfSpreadPerc = fee * (1 + @@takeRate + @@takeIncrement * i)
      halfSpread = midpt * halfSpreadPerc
      bidPrice = midpt - halfSpread
      askPrice = midpt + halfSpread

      bid = Quote.new true, bidPrice, @@defaultSize
      ask = Quote.new false, askPrice, @@defaultSize

      book.add bid
      book.add ask
      @@log.info "new order book level #{i} : bid #{bid.size} at #{bid.price}, ask #{ask.size} at #{ask.price}"
    end

    @exch.fetchOrders
    @exch.setOrders book
  end
end
