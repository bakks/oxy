require 'mechanize'
require 'faraday'
require 'base64'
require 'json'

MTGOX_KEY       = '7d71c7f4-7ff3-454e-87a5-6851a4962edf'
MTGOX_SECRET    = 'KjUXf1eyq/JgX3+LFVm4BzrpQIeqx02YI9LveEzfIO37PQ8Dy8fIFlO8s84eARM9LvVE/ujesyJf41j0y6fcGg=='
MTGOX_USERNAME  = 'tourbillon'
MTGOX_PASSWORD  = 'Q3eGPwULhPtn'
MTGOX_DOMAIN    = 'https://mtgox.com'

class MtGox
  @@log = Log.new('mtgox')
  attr_reader :fee
  attr_reader :balance
  attr_reader :orders
  attr_reader :trades
  attr_reader :depth
  attr_reader :token

  def initialize
    @@log.info 'initializing MtGox...'

    @key        = MTGOX_KEY
    @secret     = MTGOX_SECRET
    @username   = MTGOX_USERNAME
    @password   = MTGOX_PASSWORD
    @domain     = MTGOX_DOMAIN

    @@log.info "domain: #{@domain}"
    @@log.info "username: #{@username}"

    @mtgox_info       = '/api/1/generic/private/info'
    @mtgox_orders     = '/api/1/generic/private/orders'
    @mtgox_depth      = '/api/1/BTCUSD/depth'
    @mtgox_fulldepth  = '/api/1/BTCUSD/fulldepth'
    @mtgox_trades     = '/api/1/BTCUSD/trades'
    @mtgox_cancel     = '/code/cancelOrder.php'
    @mtgox_add        = '/api/1/BTCUSD/private/order/add'

    getToken

    @client = Faraday.new(:url => @domain) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end

    @depth      = Book.new
    @orders     = Book.new
    @fee        = nil
    @balance    = {}

    @@log.info 'initialized MtGox'
  end

  def getToken
    @agent = Mechanize.new
    path = @domain + '/code/login.json'

    t = Time.now
    response = @agent.post(path,
      {:username => @username, :password => @password})

    status = response.code.to_i
    Persistence::writeHttpRequest response.uri.to_s, t, status
    @@log.error "login returned #{status}, exiting" unless status == 200

    page = @agent.get(@domain)
    @token = /var token = "(\w+)"/.match(page.body)[1]
    raise 'no token found' unless @token

    @@log.info 'token: ' + @token
  end

  def midpoint
    return nil if depth.bids.size == 0 or depth.asks.size == 0
    return (depth.bids[0].price + depth.asks[0].price) / 2
  end

  def value
    return nil unless midpoint and @balance[:USD] and @balance[:BTC]
    return @balance[:USD] + @balance[:BTC] * midpoint
  end

  def addOrder x, price = nil, size = nil
    if x.is_a? Quote
      request @mtgox_add, {
        :type => (x.isBuy ? 'bid' : 'ask'),
        :amount_int => x.size * 100000000,
        :price_int => x.price * 100000
      }
    elsif x.class == TrueClass or x.class == FalseClass
      @@log.error 'invalid arguments to addOrder' unless price and size
      request @mtgox_add, {
        :type => (x ? 'bid' : 'ask'),
        :amount_int => size * 100000000,
        :price_int => price * 100000
      }
    else
      @@log.error 'invalid arguments to addOrder'
    end
  end

  def setOrders newBook, threshold
    @@log.info "setOrders #{newBook.bids.size} bids #{newBook.asks.size} asks"

    newOrders = []

    i = 0
    newBook.bids.each do |bid|
      flag = false

      while orders.bids.size > 0 and i < orders.bids.length
        oldBid = orders.bids[i]

        if oldBid.price > bid.price * (1 + threshold)
          cancelOrder oldBid
          orders.removeBid i
          next
        elsif oldBid.price > bid.price * (1 - threshold)
          i += 1
          flag = true
          break
        end
        break
      end

      newOrders << bid unless flag
    end

    i = 0
    newBook.asks.each do |ask|
      flag = false

      while orders.asks.size > 0 and i < orders.asks.length
        oldAsk = orders.asks[i]

        if oldAsk.price < ask.price * (1 - threshold)
          cancelOrder oldAsk
          orders.removeAsk i
          next
        elsif oldAsk.price < ask.price * (1 + threshold)
          i += 1
          flag = true
          break
        end
        break
      end

      newOrders << ask unless flag
    end

    newOrders.each { |o| addOrder(o) }
  end

  def cancelAll
    @@log.info "cancelAll #{orders.bids.size} bids #{orders.asks.size} asks"
    @orders.bids.each { |o| cancelOrder(o) }
    @orders.asks.each { |o| cancelOrder(o) }
  end

  def cancelOrder order
    @@log.error 'order must be a Quote' unless order.is_a? Quote
    unless order.extId != nil and order.extId != ""
      @@log.error 'order has no external id' 
    end

    type = (order.isBuy ? 'bid' : 'ask')
    @@log.info "cancelOrder #{type} #{order.size} at #{order.price}, #{order.start ? order.start.iso8601 : ''}, #{order.extId}"

    t = Time.now
    r = @agent.post(@domain + @mtgox_cancel, {
      :token => @token,
      :oid => order.extId
    })

    response = JSON(r.body)
    Persistence::writeHttpRequest r.uri.to_s, t, r.code, response

    @@log.debug "post #{@mtgox_cancel} token=#{@token}&oid=#{order.extId}"
    @@log.warn "got back #{r.code} from #{@mtgox_cancel}" unless r.code == 200
    @@log.warn "failed to cancel with error: #{response['error']}" if response['error']
  end

  def fetchAccounts
    @@log.info 'fetchAccounts'
    x = request @mtgox_info

    @fee = x['Trade_Fee'] * 0.01

    s = ''

    x['Wallets'].each do |k, v|
      balance = v['Balance']['value'].to_f
      @balance[k.intern] = balance
      s += "#{k} #{balance} "
    end

    @@log.info "info: fee #{@fee} #{s}"

    if midpoint
      value = @balance[:BTC] * midpoint + @balance[:USD]
      @@log.info "info: value $#{value}"
    end
  end

  def fetchOrders
    @@log.info 'fetchOrders'
    x = request @mtgox_orders

    @orders.clear

    bids = 0
    asks = 0

    x.each do |o|
      type = o['type']
      isBuy = (type == 'bid')
      @@log.error "bad order type: #{type}" unless type == 'bid' or type == 'ask'

      price = o['price']['value'].to_f
      size = o['amount']['value'].to_f
      t = o['priority'].to_i
      sec = t / 1000000
      nsec = (t - (t / 1000000) * 1000000)
      start = Time.at(sec, nsec).getutc
      extId = o['oid']

      order = Quote.new(isBuy, price, size, start, nil, extId)
      @orders.add order

      @@log.info "found order #{type} #{size} at #{price}, #{start.iso8601}, #{extId}"
      bids += 1 if isBuy
      asks += 1 if !isBuy
    end

    @@log.info "found #{bids} bids #{asks} asks"
  end

  def fetchTrades
    @@log.info 'fetchTrades'
    x = request @mtgox_trades

    @trades = []

    x.each do |t|
      type = t['trade_type']
      isBuy = (t['trade_type'] == 'bid')
      raise "bad trade type: #{type}" unless type == 'bid' or type == 'ask'

      price = t['price'].to_f
      size = t['amount'].to_f
      timestamp = Time.at(t['date']).getutc
      extId = t['tid']

      trade = Trade.new isBuy, price, size, timestamp, extId
      @trades << trade
    end

    Persistence::writeTrades @trades

    @@log.info "fetched #{@trades.size} trades"
  end

  def fetchDepth
    @@log.info 'fetchDepth'

    x = request @mtgox_depth
    @depth.clear

    x['bids'].each do |x|
      isBuy = true
      price = x['price']
      size = x['amount']
      t = x['stamp'].to_i
      sec = t / 1000000
      nsec = (t - (t / 1000000) * 1000000)
      timestamp = Time.at(sec, nsec).getutc

      quote = Quote.new isBuy, price, size, timestamp
      @depth.add quote
    end

    x['asks'].each do |x|
      isBuy = false
      price = x['price']
      size = x['amount']
      t = x['stamp'].to_i
      sec = t / 1000000
      nsec = (t - (t / 1000000) * 1000000)
      timestamp = Time.at(sec, nsec).getutc

      quote = Quote.new isBuy, price, size, timestamp
      @depth.add quote
    end

    Persistence::writeBook @depth

    @@log.info "fetched #{@depth.bids.size} bids #{@depth.asks.size} asks"
  end

  private

  def request path, args = {}
    args[:nonce] = Time.now.getutc.to_i * 1000000000 + Time.now.getutc.nsec
    body = args.collect{|k, v| "#{k}=#{v}"} * '&'

    signature = Base64.strict_encode64(
      OpenSSL::HMAC.digest 'sha512',
      Base64.decode64(@secret),
      body
    )

    headers = {
      'Rest-Key' => @key,
      'Rest-Sign' => signature,
      'Content-type' => 'application/x-www-form-urlencoded'
    }

    @@log.debug "post #{path} #{body}"
    t = Time.now
    response = @client.post(path, body, headers)

    unless response.status == 200
      @@log.warn "got back #{response.status} from #{path}" 
    end
  
    r = JSON(response.body)
    path = @client.scheme + "://" + @client.host + path
    Persistence::writeHttpRequest path, t, response.status, r

    if r['result'] != 'success' || !r['return']
      @@log.warn "no result from #{path} body: #{response.body}"
    end
    
    return r['return']
  end

end

