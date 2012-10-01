require 'spec_helper'
require 'oxy'
require 'webmock/rspec'

describe Strategy do

  it 'should create and set orders' do

    fee = 0.006
    midpt = 10.5

    testBook = Book.new
    testBook.add Quote.new(true, 10, 1)
    testBook.add Quote.new(false, 11, 1)

    exch = mock('MtGox')
    exch.stubs(:balance).returns({:USD => 100, :BTC => 100})
    exch.stubs(:fetchDepth).once
    exch.stubs(:fetchOrders).twice
    exch.stubs(:fetchAccounts).twice
    exch.stubs(:value).returns(100).twice
    exch.stubs(:midpoint).returns(10).twice
    exch.stubs(:depth).returns(testBook).once
    exch.stubs(:fee).returns(0.006).once
    exch.stubs(:cancelAll).once
    exch.stubs(:midpoint).returns(10.5).once

    Strategy.stubs(:sleep)

    MtGox.stubs(:new).returns(exch)
    strat = Strategy.new(MtGox.new)
    takeRate = strat::takeRate
    takeRate.should be > 0

    exch.stubs(:setOrders).with do |book|
      book.bids.size.should == 1
      book.asks.size.should == 1

      bid = book.bids[0]
      bid.isBuy.should == true
      bid.size.should == 0.1
      bid.price.should == midpt - midpt * fee * (1 + takeRate)

      bid = book.asks[0]
      bid.isBuy.should == false
      bid.size.should == 0.1
      bid.price.should == midpt + midpt * fee * (1 + takeRate)
    end

    strat.stop
    strat.run
  end

end
