def verifyAccounts(mtgox)
  mtgox.fee.should be <= 0.006
  mtgox.fee.should be > 0

  mtgox.balance[:BTC].should be >= 0
  mtgox.balance[:BTC].should be <= 1000

  mtgox.balance[:USD].should be >= 0
  mtgox.balance[:USD].should be <= 5000
end

def verifyTrades(mtgox)
  bids = 0
  asks = 0

  mtgox.trades.each do |trade|
    if trade.price < 5 or trade.price > 15
      puts "extreme trade price: #{trade.price}"
    end

    if trade.size < 0.001 or trade.size > 999
      puts "extreme trade size: #{trade.size}"
    end

    if trade.isBuy
      bids += 1
    else
      asks += 1
    end

    trade.timestamp.to_i.should be > Time.utc(2012, 'jan', 1, 0, 0, 0).to_i
    trade.timestamp.to_i.should be < Time.now.to_i
    trade.extId.should_not be nil
  end

  bids.should be > 200
  asks.should be > 200
end

def verifyDepth(mtgox)
  depth = mtgox.depth

  depth.bids[0].price.should be < depth.asks[0].price
  depth.bids[0].price.should be > depth.asks[0].price - 2
  depth.bids.size.should be > 500
  depth.asks.size.should be > 500

  depth.bids.each { |x| verifyQuote(x) }
  depth.asks.each { |x| verifyQuote(x) }
end

def verifyQuote(quote)
  if quote.price < 0.00001 or quote.price > 10000000
    puts "extreme quote price: #{quote.price}"
  end

  if quote.size < 0.00001 or quote.size > 100000
    puts "extreme quote size: #{quote.size}"
  end

  quote.start.to_i.should be > Time.utc(2011, 'jun', 1, 0, 0, 0).to_i
  quote.start.to_i.should be < Time.now.to_i
end
