require 'spec_helper'
require 'oxy'

describe Persistence do

  before(:all) do 
    @mongodb = Persistence::db
    @mongodb['requests'].drop
    @mongodb['quotes'].drop
    @mongodb['trades'].drop
  end

  it 'should persist http requests' do
    pp Time.now.to_i
    stamp = Time.at(Time.now.to_i).getutc
    @mongodb.get_last_error
    Persistence::writeHttpRequest '/test', stamp, 200, {'x' => 1}
    @mongodb.get_last_error

    cursor = @mongodb['requests'].find({:path => '/test', :timestamp => stamp})
    a = cursor.to_a
    a.size.should == 1
    doc = a[0]

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
  end

  it 'should persist quotes' do
    t = Time.now.getutc
    q = Quote.new(true, 10, 10, t)
    
    r = @mongodb['quotes'].find(:is_buy => true, :start => t)
    r.to_a.size.should == 0

    Persistence::writeQuote q
    r = @mongodb['quotes'].find(:is_buy => true, :start => t)
    quotes = r.to_a
    quotes.size.should == 1
    checkquote q, quotes[0]

    Persistence::writeQuote q
    r = @mongodb['quotes'].find(:is_buy => true, :start => t)
    quotes = r.to_a
    quotes.size.should == 1
    checkquote q, quotes[0]
  end

  it 'should persist a book' do
    t1 = Time.now.getutc - 10
    bid = Quote.new(true, 10, 10, t1)
    t2 = Time.now.getutc
    ask = Quote.new(false, 10, 10, t2)

    book = Book.new
    book.add bid
    book.add ask

    Persistence::writeBook book

    r = @mongodb['quotes'].find(:is_buy => true, :start => t1)
    quotes = r.to_a
    quotes.size.should == 1
    checkquote bid, quotes[0]

    r = @mongodb['quotes'].find(:is_buy => false, :start => t2)
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
