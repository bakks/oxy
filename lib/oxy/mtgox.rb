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
  attr_reader :fee
  attr_reader :balance
  attr_reader :orders
  attr_reader :trades
  attr_reader :depth
  attr_reader :token

  def initialize
    puts 'initializing MtGox...'

    @key        = MTGOX_KEY
    @secret     = MTGOX_SECRET
    @username   = MTGOX_USERNAME
    @password   = MTGOX_PASSWORD
    @domain     = MTGOX_DOMAIN

    @mtgox_info       = '/api/1/generic/private/info'
    @mtgox_orders     = '/api/1/generic/private/orders'
    @mtgox_fulldepth  = '/api/1/BTCUSD/fulldepth'
    @mtgox_trades     = '/api/1/BTCUSD/trades'
    @mtgox_cancel     = '/code/cancelOrder.php'
    @mtgox_add        = '/api/1/BTCUSD/private/order/add'

    @agent = Mechanize.new
    response = @agent.post(@domain + '/code/login.json',
      {:username => @username, :password => @password})

    puts response.body

    page = @agent.get(@domain)
    @token = /var token = "(\w+)"/.match(page.body)[1]
    raise 'no token found' unless @token

    puts 'token: ' + @token

    @client = Faraday.new(:url => @domain) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end

    @depth      = Book.new
    @orders     = Book.new
    @fee        = -1
    @balance    = {}

    puts 'initialized MtGox'
  end

  def midpoint
    return -1 if depth.bids.size == 0 or depth.asks.size == 0
    return (depth.bids[0].price + depth.asks[0].price) / 2
  end

  def addOrder x, price = nil, size = nil
    if x.is_a? Quote
      request @mtgox_add, {
        :type => (x.isBuy ? 'bid' : 'ask'),
        :amount_int => x.size * 100000000,
        :price_int => x.price * 100000
      }
    elsif x.class == TrueClass or x.class == FalseClass
      raise 'invalid arguments to addOrder' unless price and size
      request @mtgox_add, {
        :type => (x ? 'bid' : 'ask'),
        :amount_int => size * 100000000,
        :price_int => price * 100000
      }
    else
      raise 'invalid arguments to addOrder'
    end
  end

  def setOrders newBook, threshold
    i = 0
    newOrders = []

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

    newOrders.each { |o| addOrder(o) }
  end

  def cancelAll
    @orders.bids.each { |o| cancelOrder(o) }
    @orders.asks.each { |o| cancelOrder(o) }
  end

  def cancelOrder order
    raise 'order must be a Quote' unless order.is_a? Quote
    unless order.extId != nil and order.extId != ""
      raise 'order has no external id' 
    end

    r = @agent.post(@domain + @mtgox_cancel, {
      :token => @token,
      :oid => order.extId
    })

    response = JSON(r.body)
    puts 'failed to cancel with error: ' + r if response['error']
  end

  def fetchAccounts
    x = request @mtgox_info

    @fee = x['Trade_Fee'] * 0.01

    x['Wallets'].each do |k, v|
      balance = v['Balance']['value'].to_f
      @balance[k.intern] = balance
    end
  end

  def fetchOrders
    x = request @mtgox_orders

    @orders.clear

    x.each do |o|
      type = o['type']
      isBuy = (type == 'bid')
      raise "bad order type: #{type}" unless type == 'bid' or type == 'ask'

      price = o['price']['value'].to_f
      size = o['amount']['value'].to_f
      t = o['priority'].to_i
      sec = t / 1000000
      nsec = (t - (t / 1000000) * 1000000)
      start = Time.at(sec, nsec)
      extId = o['oid']

      order = Quote.new(isBuy, price, size, start, nil, extId)
      @orders.add order
    end
  end

  def fetchTrades
    x = request @mtgox_trades

    @trades = []

    x.each do |t|
      type = t['trade_type']
      isBuy = (t['trade_type'] == 'bid')
      raise "bad trade type: #{type}" unless type == 'bid' or type == 'ask'

      price = t['price'].to_f
      size = t['amount'].to_f
      timestamp = Time.at(t['date'])
      extId = t['tid']

      trade = Trade.new isBuy, price, size, timestamp, extId
      @trades << trade
    end
  end

  def fetchDepth
    x = request @mtgox_fulldepth
    @depth.clear

    x['bids'].each do |x|
      isBuy = true
      price = x['price']
      size = x['amount']
      t = x['stamp'].to_i
      sec = t / 1000000
      nsec = (t - (t / 1000000) * 1000000)
      timestamp = Time.at(sec, nsec)

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
      timestamp = Time.at(sec, nsec)

      quote = Quote.new isBuy, price, size, timestamp
      @depth.add quote
    end
  end

  private

  def request path, args = {}
    args[:nonce] = Time.now.to_i * 1000000000 + Time.now.nsec
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

    response = @client.post(path, body, headers)

    unless response.status == 200
      puts "got back #{response.status} from #{path}" 
    end
  
    r = JSON(response.body)

    if r['result'] != 'success' || !r['return']
      puts "no result from #{path} body: #{response.body}"
    end
    
    return r['return']
  end

end

