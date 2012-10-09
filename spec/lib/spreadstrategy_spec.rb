require 'spec_helper'
require 'oxy'
require 'webmock/rspec'

describe SpreadStrategy do

  it 'should create and set orders' do

    fee = 0.006
    midpt = 10.5

    testBook = Book.new
    testBook.set Quote.new(true, 10, 1)
    testBook.set Quote.new(false, 11, 1)

    exch = mock('MtGox')
    exch.stubs(:balance).returns({:USD => 100, :BTC => 100})
    exch.stubs(:bid).twice.returns(10)
    exch.stubs(:ask).twice.returns(11)
    exch.stubs(:fetchOrders).twice
    exch.stubs(:fetchAccounts)
    exch.stubs(:fetchDepth)
    exch.stubs(:value).returns(100).times(3)
    exch.stubs(:midpoint).returns(10.5).times(5)
    exch.stubs(:fee).returns(0.006).twice
    exch.stubs(:cancelAll).once

    SpreadStrategy.stubs(:sleep)

    MtGox.stubs(:new).returns(exch)
    strat = SpreadStrategy.new(MtGox.new)
    takeRate = strat::takeRate
    takeRate.should be > 0

    exch.stubs(:setOrders).with do |book, threshold|
      book.bids.size.should == 1
      book.asks.size.should == 1

      bid = book.bids[0]
      bid.isBuy.should == true
      bid.size.should == strat.defaultSize
      bid.price.should == midpt - midpt * fee * (1 + takeRate)

      bid = book.asks[0]
      bid.isBuy.should == false
      bid.size.should == strat.defaultSize
      bid.price.should == midpt + midpt * fee * (1 + takeRate)

      threshold.should == 0.005
    end

    strat.iteration
  end

end
