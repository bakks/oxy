class Quote
  attr_reader :isBuy
  attr_reader :price
  attr_reader :size
  attr_reader :start
  attr_reader :finish
  attr_reader :extId

  def initialize isBuy = nil, price = nil, size = nil, start = nil, finish = nil, extId = nil
    @isBuy = isBuy
    @price = price
    @size = size
    @start = start
    @finish = finish
    @extId = extId
  end

  def equals o
    @isBuy == o.isBuy and @price == o.price and @size == o.size and @start == o.start and @finish == o.finish and @extId == extId
  end
end

class Trade
  attr_reader :isBuy
  attr_reader :price
  attr_reader :size
  attr_reader :timestamp
  attr_reader :extId

  def initialize isBuy = nil, price = nil, size = nil, timestamp = nil, extId = nil
    @isBuy = isBuy
    @price = price
    @size = size
    @timestamp = timestamp
    @extId = extId
  end
end
