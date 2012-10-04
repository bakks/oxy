require 'mongo'

class Persistence
  @@log = Log.new('persistence')
  @@quotes = 'quotes'
  @@trades = 'trades'
  @@requests = 'requests'

  def self.db
    return $mongodb if $mongodb

    host = 'localhost'
    port = 27017
    name = 'oxy_' + $env.to_s
    @@log.info("connecting to mongo host #{host} port #{port}...")
    $mongodb = Mongo::Connection.new(host, port)[name]
    @@log.info("connected to mongo, using database #{name}")

    $mongodb
  end

  def self.writeHttpRequest path, timestamp, status, document = nil
    x = {
      :path => path,
      :timestamp => timestamp.getutc,
      :status => status.to_i,
      :doc => document
    }

    db[@@requests].insert(x)
    @@log.debug "write http request #{x}"
  end

  def self.writeQuote quote
    x = {
      :is_buy => quote.isBuy,
      :price => quote.price,
      :size => quote.size,
      :start => (quote.start ? quote.start.getutc : nil),
      :finish => (quote.finish ? quote.finish.getutc : nil),
      :extId => quote.extId
    }

    cond = {
      :is_buy => quote.isBuy,
      :price => quote.price,
      :size => quote.size,
      :start => (quote.start ? quote.start.getutc : nil)
    }

    db[@@quotes].update(cond, x, :upsert => true)
    @@log.debug "write quote #{x}"
  end

  def self.writeBook book
    @@log.debug 'writing book'
    book.bids.each { |bid| writeQuote(bid) }
    book.asks.each { |ask| writeQuote(ask) }
  end

  def self.writeTrade trade
    x = {
      :is_buy => trade.isBuy,
      :price => trade.price,
      :size => trade.size,
      :timestamp => (trade.timestamp ? trade.timestamp.getutc : nil),
      :ext_id => trade.extId
    }

    cond = {
      :ext_id => trade.extId
    }

    db[@@trades].update(cond, x, :upsert => true)
    @@log.debug "write trade #{x}"
    return !db.get_last_error['updatedExisting']
  end

  def self.writeTrades trades
    @@log.debug 'writing trades'
    trades.sort_by! { |x| x.timestamp }
    trades.reverse!

    for i in 0..(trades.size - 1)
      return unless writeTrade(trades[i])
    end
  end
end
