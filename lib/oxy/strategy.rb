class Strategy
  @@log = Log.new 'strategy'

  def initialize name, exchange
    @log = Log.new name
    @@log.info "initializing strategy #{name} ..."

    @exch = exchange
    @exch.fetchDepth
    @exch.fetchOrders
    @exch.cancelAll
    @exch.fetchAccounts

    @startValue = @exch.value
    @startMidpt = @exch.midpoint
    @startUSD   = @exch.balance[:USD]
    @startBTC   = @exch.balance[:BTC]

    @@log.info "starting value $#{@startValue} exchange rate #{@startMidpt}"
  end

  def iteration
    fee = @exch.fee
    midpt = @exch.midpoint

    @@log.fatal "no market depth" unless @exch.bid and @exch.ask
    @@log.fatal "bad fee: #{fee}" if !fee or fee < 0 or fee > 0.006
    @@log.fatal "bad midpt: #{midpt}" if !midpt or midpt < 4 or midpt > 20
    @@log.fatal "bad spread: #{@exch.bid} x #{@exch.ask}" if @exch.bid >= @exch.ask

    book = Book.new
    book = setOrders book

    @exch.fetchAccounts
    @exch.fetchOrders
    @exch.setOrders book, priceThreshold

    printInfo
  end

  def printInfo
    @@log.info "value $#{@exch.value} exchange rate #{@exch.midpoint}"
    @@log.info "value delta : $#{@exch.value - @startValue}"
    @@log.info "rate delta  : #{@exch.midpoint - @startMidpt}"
    @@log.info "USD delta   : #{@exch.balance[:USD] - @startUSD}"
    @@log.info "BTC delta   : #{@exch.balance[:BTC] - @startBTC}"
  end

end
