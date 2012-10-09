require 'spec_helper'
require 'oxy'
require 'spec_common'

describe MtGox do

  before(:all) do
    @mtgox = MtGox.new
  end

  it 'should stream quotes', :integration => true do
    scheduler = mock('Scheduler')
    scheduler.stubs(:push).at_least(2).with do |label, msg|
      label.should == :stream
      msg.size.should be > 2
      pp msg
    end

    stream = @mtgox.start_stream scheduler
    sleep 10
    stream.stop
  end

  it 'should fetch accounts', :integration => true do
    @mtgox.fetchAccounts
    verifyAccounts @mtgox
  end

  it 'should fetch depth', :integration => true do
    @mtgox.fetchDepth
    verifyDepth @mtgox
  end

  it 'should add and cancel', :integration => true do
    @mtgox.fetchOrders
    @mtgox.cancelAll
    @mtgox.fetchOrders

    @mtgox.orders.bids.size.should == 0
    @mtgox.orders.asks.size.should == 0

    bidPrice = 0.1
    askPrice = 99999999.1
    size = 0.1

    @mtgox.addOrder true, bidPrice, size
    @mtgox.addOrder false, askPrice, size
    @mtgox.fetchOrders

    @mtgox.orders.bids.size.should == 1
    @mtgox.orders.bids[0].price.should == bidPrice
    @mtgox.orders.bids[0].size.should == size
    @mtgox.orders.asks.size.should == 1
    @mtgox.orders.asks[0].price.should == askPrice
    @mtgox.orders.asks[0].size.should == size

    tries = 0

    while tries < 4
      @mtgox.cancelAll

      sleep 1

      @mtgox.fetchOrders

      tries += 1
    end

    @mtgox.orders.bids.size.should == 0
    @mtgox.orders.asks.size.should == 0
  end

end
