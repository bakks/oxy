class Book
  @@log = Log.new 'book'

  def initialize
    @bids = []
    @asks = []
  end

  def clear
    @bids = []
    @asks = []
  end

  def findBid price
    i = searchBids price
    return @bids[i] if @bids[i] and @bids[i].price == price
    return nil
  end

  def findAsk price
    i = searchAsks price
    return @asks[i] if @asks[i] and @asks[i].price == price
    return nil
  end

  def searchAsks price
    return 0 if @asks.size == 0
    return (@asks[0].price < price ? 1 : 0) if @asks.size == 1

    start = 0
    finish = @asks.size
    i = 0

    while finish > start + 1
      i = start + (finish - start) / 2
      
      start = i if @asks[i].price <= price
      finish = i if @asks[i].price >= price
      return i if start == finish
    end

    return start + 1 unless @asks[start].price > price
    return start
  end

  def searchBids price
    return 0 if @bids.size == 0
    return (@bids[0].price > price ? 1 : 0) if @bids.size == 1

    start = 0
    finish = @bids.size
    i = 0

    while finish > start + 1
      i = start + (finish - start) / 2
      
      start = i if @bids[i].price >= price
      finish = i if @bids[i].price <= price
      return i if start == finish
    end

    return start + 1 unless @bids[start].price < price
    return start
  end

  def set(quote)
    raise 'nil quote' unless quote
    raise 'must be Quote' unless quote.is_a? Quote

    arr = quote.isBuy ? @bids : @asks
    side = quote.isBuy ? 'buy' : 'sell'
    i = quote.isBuy ? searchBids(quote.price) : searchAsks(quote.price)

    if i >= 0 and arr[i] and quote.price == arr[i].price
      x = arr[i]
      x.finish = quote.start

      if quote.size == 0
        @@log.debug "deleting #{side} #{arr[i].size} at #{arr[i].price}"
        arr.delete_at(i)
      elsif quote.size < 0
        @@log.debug "subtracting #{quote.size} from #{arr[i].size}"
        quote = Quote.new(quote.isBuy, x.size + quote.size, quote.price, quote.start, quote.finish, quote.extId)
        Persistence::writeQuote quote if quote.size > 0
      else
        arr[i] = quote
        Persistence::writeQuote quote
      end

      raise "quote size #{x.size}  #{x}  #{quote}" if x.size <= 0
      Persistence::writeQuote x
      return x
    elsif quote.size > 0
      arr.insert(i, quote)
      Persistence::writeQuote quote
      return nil
    end
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
