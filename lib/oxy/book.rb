class Book
  @bids = []
  @asks = []

  def initialize

  end

  def clear
    @bids = []
    @asks = []
  end

  def add(quote)
    raise 'must be Quote' unless quote === Quote

    if quote.isBuy
      for i in 0..@bids.size
        if quote.price > @bids[i].price
          @bids.insert(i, quote)
          return
        end
      end
      @bids << quote
    else
      for i in 0..@asks.size
        if quote.price < @asks[i].price
          @asks.insert(i, quote)
          return
        end
      end
      @asks << quote
    end
  end

  def bids
    @bids.size
  end

  def asks
    @asks.size
  end

  def bid i
    @bids[i]
  end

  def ask i
    @asks[i]
  end

  def remove quote
    raise 'must be Quote' unless quote === Quote

    if quote.isBuy
      @bids.delete_if { |x| x.equals(quote) }
    else
      @asks.delete_if { |x| x.equals(quote) }
    end
  end

  def removeBid i
    @bids.delete_at i
  end

  def removeAsk i
    @asks.delete_at i
  end

  def print
    puts "-- book -------------------------"
    @asks.reverse.each { |x| puts "ask\t" + x.price + "\t" + x.size }
    @bids.each { |x| puts "bid\t" + x.price + "\t" + x.size }
    puts "---------------------------------"
  end
end