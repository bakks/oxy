require_relative 'strategy'

class DepthStrategy < Strategy
  @@placementDepth    = 10
  @@placementInterval = 0.001
  @@priceThreshold    = 0.0
  @@defaultSize       = 0.1

  def initialize exchange
    super 'depthstrat', exchange

    @log.info "placementDepth     : #{@@placementDepth}"
    @log.info "placementInterval  : #{@@placementInterval}"
    @log.info "priceThreshold     : #{@@priceThreshold}"
    @log.info "defaultSize        : #{@@defaultSize}"
    @log.info 'strategy initialized'
  end

  def placementDepth
    @@placementDepth
  end

  def placementInterval
    @@placementInterval
  end

  def priceThreshold
    @@priceThreshold
  end

  def setOrders book
    fee = @exch.fee
    depth = @exch.depth

    lastBid = nil
    lastAsk = nil

    bidSum = 0
    i = 0
    while i < depth.bids.size and bidSum < @@placementDepth
      bidSum += depth.bids[i].size
      lastBid = depth.bids[i].price
      i += 1
    end

    askSum = 0
    j = 0
    while j < depth.asks.size and askSum < @@placementDepth
      askSum += depth.asks[j].size
      lastAsk = depth.asks[j].price
      j += 1
    end

    unless lastBid and lastAsk
      @log.warn "could not find #{@@placementDepth} of depth, bid #{lastBid} ask #{lastAsk}"
      return book
    end

    bidPrice = lastBid + @@placementInterval
    askPrice = lastAsk - @@placementInterval

    gap = (askPrice - bidPrice) / bidPrice
    minGap = 2 * fee

    unless gap > minGap
      @log.warn "bid and ask too close to trade, bid #{bidPrice} ask #{askPrice} gap #{gap}% minGap #{minGap}%"
      return book
    end

    bid = Quote.new true, bidPrice, @@defaultSize
    ask = Quote.new false, askPrice, @@defaultSize

    book.set bid
    book.set ask
    
    @log.info "new order book level on midpt #{@exch.midpoint} : bid #{bid.size} at #{bid.price}, ask #{ask.size} at #{ask.price}"

    book
  end

end
