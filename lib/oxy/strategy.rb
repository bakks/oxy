class Strategy
  @@log               = Log.new 'strat'
  @@interval          = 15
  @@takeRate          = 0.1
  @@takeIncrement     = 0.2
  @@levels            = 1
  @@defaultSize       = 0.1
  @@priceThreshold    = 0.005
  @@run               = true

  def initialize exchange
    @@log.info 'initializing strategy...'
    @exch = exchange
    @exch.fetchOrders
    @exch.cancelAll

    @@log.info "interval        : #{@@interval}"
    @@log.info "takeRate        : #{@@takeRate}"
    @@log.info "takeIncrement   : #{@@takeIncrement}"
    @@log.info "levels          : #{@@levels}"
    @@log.info "defaultSize     : #{@@defaultSize}"
    @@log.info "priceThreshold  : #{@@priceThreshold}"

    @@log.info 'strategy initialized'
  end

  def takeRate
    @@takeRate
  end

  def stop
    @@run = false
  end

  def start
    @@run = true
    run
  end

  def run
    @@log.info 'running strategy...'

    @exch.fetchDepth
    @exch.fetchAccounts
    startValue = @exch.value
    startMidpt = @exch.midpoint
    startUSD   = @exch.balance[:USD]
    startBTC   = @exch.balance[:BTC]

    @@log.info "starting value $#{startValue} exchange rate #{startMidpt}"

    while true
      @exch.fetchAccounts
      iteration

      @@log.info "value $#{@exch.value} exchange rate #{@exch.midpoint}"
      @@log.info "value delta: $#{@exch.value - startValue}"
      @@log.info "rate delta : #{@exch.midpoint - startMidpt}"
      @@log.info "USD delta  : #{@exch.balance[:USD] - startUSD}"
      @@log.info "BTC delta  : #{@exch.balance[:BTC] - startBTC}"
      @@log.info "sleeping for #{@@interval}s"

      break unless @@run
      sleep @@interval
      break unless @@run
      @@log.info 'awake, running strategy'
    end

    @@log.info 'exiting strategy'
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
    @exch.setOrders book, @@priceThreshold
  end
end
