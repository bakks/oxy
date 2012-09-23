require 'spec_helper'
require 'oxy'

describe Persistence do

  before(:all) do 
    @mongodb = Mongo::Connection.new['oxy_' + $env.to_s]
    @mongodb['requests'].drop
    @mongodb['quotes'].drop
    @mongodb['trades'].drop
  end

  it 'should persist http requests' do
    stamp = Time.now.getutc
    Persistence::writeHttpRequest '/test', stamp, 200, {'x' => 1}

    cursor = @mongodb['requests'].find({:path => '/test', :timestamp => stamp})
    cursor.has_next?.should == true
    doc = cursor.next

    doc['path'].should == '/test'
    doc['timestamp'].to_s.should == stamp.to_s
    doc['status'].should == 200
    doc['doc']['x'].should == 1
  end

  def checkquote a, b
    a.isBuy.should == b['is_buy']
    a.price.should == b['price']
    a.size.should == b['size']
    a.start.to_s.should == b['start'].to_s
    a.finish.to_s.should == b['finish'].to_s
    a.extId.should == b['ext_id']
  end

  it 'should persist quotes' do
    id = 'atoehu83o-aoeu'
    q = Quote.new(true, 10, 10, Time.now.getutc, nil, id)
    
    r = @mongodb['quotes'].find(:ext_id => id)
    r.to_a.size.should == 0

    Persistence::writeQuote q
    r = @mongodb['quotes'].find(:ext_id => id)
    quotes = r.to_a
    quotes.size.should == 1
    checkquote q, quotes[0]

    Persistence::writeQuote q
    r = @mongodb['quotes'].find(:ext_id => id)
    quotes = r.to_a
    quotes.size.should == 1
    checkquote q, quotes[0]
  end

  it 'should persist a book' do
    id1 = 'ato83o-aoeu1'
    bid = Quote.new(true, 10, 10, Time.now.getutc, nil, id1)

    id2 = 'ato83o-aoeu2'
    ask = Quote.new(false, 10, 10, Time.now.getutc, nil, id2)

    book = Book.new
    book.add bid
    book.add ask

    Persistence::writeBook book

    r = @mongodb['quotes'].find(:ext_id => id1)
    quotes = r.to_a
    quotes.size.should == 1
    checkquote bid, quotes[0]

    r = @mongodb['quotes'].find(:ext_id => id2)
    quotes = r.to_a
    quotes.size.should == 1
    checkquote ask, quotes[0]
  end

  def checktrade a, b
    a.isBuy.should == b['is_buy']
    a.price.should == b['price']
    a.size.should == b['size']
    a.timestamp.to_s.should == b['timestamp'].to_s
    a.extId.should == b['ext_id']
  end

  it 'should persist trades' do
    time1 = (Time.now - 10).getutc
    id1 = 'aoeuhtneoh93'
    t = Trade.new true, 10, 20, time1, id1
    Persistence::writeTrade t

    r = @mongodb['trades'].find(:ext_id => id1)
    a = r.to_a
    a.size.should == 1
    checktrade t, a[0]

    time2 = Time.now.getutc
    time2.should be > time1
    id2 = '8ouunaoteuh'
    t2 = Trade.new true, 10, 20, time2, id2

    trades = [t, t2]
    Persistence::writeTrades trades

    r = @mongodb['trades'].find(:ext_id => id2)
    a = r.to_a
    a.size.should == 1
    checktrade t2, a[0]
    
    @mongodb['trades'].count.should == 2
  end
end
