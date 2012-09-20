require 'mongo'

class Persistence
  @@log = Log.new('mtgox')

  def self.db
    host = 'localhost'
    port = 27017
    name = 'oxy_' + $env.to_s
    @@log.info("connecting to mongo host #{host} port #{port}...")
    $mongodb = Mongo::Connection.new(host, port)[name]
    @@log.info("connected to mongo, using database #{name}")
  end

  def self.writeHttpRequest path, timestamp, status, document
    x = {
      :path => path,
      :timestamp => timestamp.getutc,
      :status => status.to_i,
      :doc => document
    }

    db['requests'].insert(x)
  end

  def self.writeQuote quote
    x = {
      :is_buy => quote.isBuy,
      :price => quote.price,
      :size => quote.size,
      :start => quote.start,
      :ext_id => quote.extId
    }

    cond = {
      :ext_id => quote.extId
    }

    db['quotes'].update(cond, x, :upsert => true)
  end

  def self.writeBook book
    book.bids.each { |bid| writeQuote(bid) }
    book.asks.each { |ask| writeQuote(ask) }
  end

end
