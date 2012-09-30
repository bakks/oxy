class Book

  def initialize
    @bids = []
    @asks = []
  end

  def clear
    @bids = []
    @asks = []
  end

  def add(quote)
    raise 'nil quote' unless quote
    raise 'must be Quote' unless quote.is_a? Quote

    if quote.isBuy
      for i in 0..(@bids.size - 1)
        if quote.price == @bids[i].price
          x = @bids[i]
          x.finish = quote.start

          if quote.size == 0
            @bids.delete_at(i)
          else
            @bids[i] = quote
          end

          return x
        elsif quote.price > @bids[i].price
          @bids.insert(i, quote)
          return nil
        end
      end
      @bids << quote
    else
      for i in 0..(@asks.size - 1)
        if quote.price == @asks[i].price
          x = @asks[i]
          x.finish = quote.start

          if quote.size == 0
            @asks.delete_at(i)
          else
            @asks[i] = quote
          end

          return x
        elsif quote.price < @asks[i].price
          @asks.insert(i, quote)
          return nil
        end
      end
      @asks << quote
    end

    nil
  end

  def bids
    @bids
  end

  def asks
    @asks
  end

  def bid i
    @bids[i]
  end

  def ask i
    @asks[i]
  end

  def remove quote
    raise 'must be Quote' unless quote.is_a? Quote

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

  def find timestamp
    x = nil
    @bids.each { |bid| x = bid if bid.start == timestamp }
    @asks.each { |ask| x = ask if ask.start == timestamp }

    return x
  end

  def print
    puts "-- book -------------------------"
    @asks.reverse.each { |x| puts "ask\t" + x.price + "\t" + x.size }
    @bids.each { |x| puts "bid\t" + x.price + "\t" + x.size }
    puts "---------------------------------"
  end
end
