class Quote
  def initialize isBuy = nil, price = nil, size = nil, start = nil, finish = nil, extId = nil
    @isBuy = isBuy
    @price = price
    @size = size
    @start = start
    @finish = finish
    @extId = extId
  end

  def equals o
    @isBuy == o.isBuy and @price == o.price and @size == o.size and @start == o.start and @end == o.end and @extId == extId
  end

  def isBuy
    @isBuy
  end

  def price
    @price
  end

  def size
    @size
  end
end
