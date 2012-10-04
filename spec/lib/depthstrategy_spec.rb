require 'spec_helper'
require 'oxy'
require 'webmock/rspec'

describe DepthStrategy do

  it 'should create and set orders' do
    fee = 0.006
    midpt = 10.5

    testBook = Book.new
    testBook.add Quote.new(true, 10, 1)
    testBook.add Quote.new(true, 9.5, 100)
    testBook.add Quote.new(false, 11, 1)
    testBook.add Quote.new(false, 11.5, 100)

    exch = mock('MtGox')
    exch.stubs(:balance).returns({:USD => 100, :BTC => 100})
    exch.stubs(:depth).once.returns(testBook)
    exch.stubs(:bid).once.returns(10)
    exch.stubs(:ask).once.returns(11)
    exch.stubs(:fetchOrders).twice
    exch.stubs(:fetchAccounts)
    exch.stubs(:fetchDepth).once
    exch.stubs(:value).returns(100).times(3)
    exch.stubs(:midpoint).returns(10.5).times(5)
    exch.stubs(:fee).returns(0.006).twice
    exch.stubs(:cancelAll).once

    DepthStrategy.stubs(:sleep)

    MtGox.stubs(:new).returns(exch)
    strat = DepthStrategy.new(exch)

    exch.stubs(:setOrders).with do |book, threshold|
      book.bids.size.should == 1
      book.asks.size.should == 1

      bid = book.bids[0]
      bid.isBuy.should == true
      bid.size.should == 0.1
      bid.price.should == 9.5 + strat.placementInterval

      bid = book.asks[0]
      bid.isBuy.should == false
      bid.size.should == 0.1
      bid.price.should == 11.5 - strat.placementInterval

      threshold.should == 0
    end

    strat.iteration
  end

  it 'should break for a spread too small' do
    fee = 0.006
    midpt = 10.5

    testBook = Book.new
    testBook.add Quote.new(true, 10, 100)
    testBook.add Quote.new(false, 10.003, 100)

    exch = mock('MtGox')
    exch.stubs(:balance).returns({:USD => 100, :BTC => 100})
    exch.stubs(:depth).returns(testBook)
    exch.stubs(:bid).returns(10)
    exch.stubs(:ask).returns(11)
    exch.stubs(:fetchOrders)
    exch.stubs(:fetchAccounts)
    exch.stubs(:fetchDepth).once
    exch.stubs(:value).returns(100)
    exch.stubs(:midpoint).returns(10.5)
    exch.stubs(:fee).returns(0.006)
    exch.stubs(:cancelAll)

    DepthStrategy.stubs(:sleep)

    MtGox.stubs(:new).returns(exch)
    strat = DepthStrategy.new(MtGox.new)

    exch.stubs(:setOrders).with do |book, threshold|
      book.bids.size.should == 0
      book.asks.size.should == 0
      threshold.should == 0
    end

    strat.iteration
  end

end
