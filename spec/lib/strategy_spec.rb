require 'spec_helper'
require 'oxy'
require 'webmock/rspec'

describe Strategy do

  it 'should create and set orders' do

    fee = 0.006
    midpt = 10.5
    takeRate = 0.2

    testBook = Book.new
    testBook.add Quote.new(true, 10, 1)
    testBook.add Quote.new(false, 11, 1)

    exch = mock('MtGox')
    exch.stubs(:fetchDepth)
    exch.stubs(:fetchOrders)
    exch.stubs(:depth).returns(testBook)
    exch.stubs(:fee).returns(0.006)
    exch.stubs(:midpoint).returns(10.5)

    exch.stubs(:setOrders).with do |book|
      book.bids.size.should == 1
      book.asks.size.should == 1

      bid = book.bids[0]
      bid.isBuy.should == true
      bid.size.should == 0.1
      bid.price.should == midpt - midpt * fee * (1 + 0.2)

      bid = book.asks[0]
      bid.isBuy.should == false
      bid.size.should == 0.1
      bid.price.should == midpt + midpt * fee * (1 + 0.2)
    end
    MtGox.stubs(:new).returns(exch)

    Strategy.new(MtGox.new).iteration
  end

end
