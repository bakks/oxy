require 'spec_helper'
require 'oxy'
require 'spec_common'
require 'webmock/rspec'

describe MtGox do

  before(:all) do
    loginResponse = asset('mtgox/login.json')
    stub_request(:post, "https://mtgox.com/code/login.json")
        .with(:body => {"password"=>"Q3eGPwULhPtn", "username"=>"tourbillon"})
        .to_return(:status => 200, :body => loginResponse)

    loggedInResponse = asset('mtgox/mtgox.com')
    stub_request(:get, 'https://mtgox.com/')
        .to_return(:status => 200, :body => loggedInResponse)
    @mtgox = MtGox.new
  end

  before(:each) do
    orders = asset('mtgox/orders.json')
    stub_request(:post, 'https://mtgox.com/api/1/generic/private/orders')
        .to_return(:body => orders)
  end

  it 'should set a new order book' do
    @mtgox.fetchOrders
    @mtgox.orders.bids.size.should == 1
    @mtgox.orders.bids[0].price.should == 10

    book = Book.new
    book.add Quote.new(true, 10.04, 0.1)
    book.add Quote.new(true, 10.01, 0.1)
    book.add Quote.new(true, 10.5, 0.1)

    #book.add Quote.new(false, 12.01, 0.1)
    #book.add Quote.new(false, 14, 0.1)

    @mtgox.expects(:cancelOrder).never
    @mtgox.expects(:addOrder).times(2)
        .with { |o| (o.isBuy && (o.price == 10.5 || o.price == 10.01)) || (!o.isBuy && o.price == 14) }

    @mtgox.setOrders book, 0.005
  end

  it 'should fetch accounts' do
    info = asset('mtgox/info.json')
    stub_request(:post, 'https://mtgox.com/api/1/generic/private/info')
        .to_return(:body => info)

    @mtgox.fetchAccounts()
    @mtgox.fee.should == 0.006
    @mtgox.balance[:BTC].should == 25.035
    @mtgox.balance[:USD].should == 22.01601

    verifyAccounts(@mtgox)
  end

  it 'should fetch orders' do
    @mtgox.fetchOrders
    orders = @mtgox.orders
    orders.bids.size.should == 1
    orders.asks.size.should == 1

    bid = orders.bids[0]
    bid.price.should == 10.0
    bid.size.should == 0.1
    bid.isBuy.should == true
    bid.start.to_i.should == 1346373055
    bid.start.nsec.should == 313253000
    bid.extId.should == 'f4a11c80-a27e-40a7-9913-2706f79ef1f6'

    ask = orders.asks[0]
    ask.price.should == 12.0
    ask.size.should == 0.1
    ask.isBuy.should == false
    ask.start.to_i.should == 1346373056
    ask.start.nsec.should == 313253000
    ask.extId.should == 'a4a11c80-a27e-40a7-9913-2706f79ef1f6'
  end

  it 'should fetch trades' do
    trades = asset('mtgox/trades.json')
    stub_request(:post, 'https://mtgox.com/api/1/BTCUSD/trades')
        .to_return(:body => trades)

    @mtgox.fetchTrades
    @mtgox.trades.size.should be > 500
    
    trade = @mtgox.trades[0]
    trade.price.should == 10.8999
    trade.size.should == 21.80517958
    trade.isBuy.should == true
    trade.timestamp.to_i.should == 1346286717
    trade.extId.should == '1346286717753221'

    verifyTrades(@mtgox)
  end

  it 'should fetch depth' do
    @mtgox.midpoint.should == nil

    depth = asset('mtgox/fulldepth.json')
    stub_request(:post, 'https://mtgox.com/api/1/BTCUSD/fulldepth')
        .to_return(:body => depth)

    @mtgox.fetchDepth
    @mtgox.depth.bids.size.should be > 200
    @mtgox.depth.asks.size.should be > 200

    bid = @mtgox.depth.bids[0]
    bid.isBuy.should == true
    bid.price.should == 10.7931
    bid.size.should == 14.08249999
    bid.start.to_i.should == 1344229187
    bid.start.nsec.should == 388217000

    ask = @mtgox.depth.asks[0]
    ask.isBuy.should == false
    ask.price.should == 10.8699
    ask.size.should == 2.99
    ask.start.to_i.should == 1344229184
    ask.start.nsec.should == 648281000

    @mtgox.midpoint.should == (10.7931 + 10.8699) / 2

    verifyDepth(@mtgox)
  end

  it 'should add orders' do
    stub_request(:post, 'https://mtgox.com/api/1/BTCUSD/private/order/add')
        .with(:body => hash_including({"amount_int"=>"400000000", "price_int"=>"200000", "type"=>"bid"}))
        .to_return(:body => '{"result":"success","return":[]}')

    @mtgox.addOrder(true, 2, 4)
  end

  it 'should cancel orders' do
    cancel = asset('mtgox/cancel.json')
    stub_request(:post, 'https://mtgox.com/code/cancelOrder.php')
        .with(:body => {'token' => @mtgox.token, 'oid' => 'abc123'})
        .to_return(:body => cancel)

    order = Quote.new(true, 1, 1, nil, nil, 'abc123')
    @mtgox.cancelOrder order
  end
end
