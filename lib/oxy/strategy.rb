class Strategy
  @@takeRate          = 0.1
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

    raise "bad fee: #{fee}" if fee < 0 or fee > 0.006
    raise "bad midpt: #{midpt}" if midpt < 4 or midpt > 20

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
    end

    @exch.fetchOrders
    @exch.setOrders book
  end
end
