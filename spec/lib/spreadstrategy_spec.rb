require 'spec_helper'
require 'oxy'
require 'webmock/rspec'

describe SpreadStrategy do
  before :each do
    @fee = 0.006
    @midpt = 10.5

    testBook = Book.new
    testBook.set Quote.new(true, 10, 1)
    testBook.set Quote.new(false, 11, 1)

    @exch = mock('MtGox')
    @exch.stubs(:balance).returns({:USD => 100, :BTC => 100})
    @exch.stubs(:bid).returns(10)
    @exch.stubs(:ask).returns(11)
    @exch.stubs(:fetchOrders)
    @exch.stubs(:fetchAccounts)
    @exch.stubs(:fetchDepth)
    @exch.stubs(:value).returns(100)
    @exch.stubs(:midpoint).returns(10.5)
    @exch.stubs(:fee).returns(0.006)
    @exch.stubs(:cancelAll)

    MtGox.stubs(:new).returns(@exch)
    @strat = SpreadStrategy.new(MtGox.new)
    @takeRate = @strat::takeRate
    @takeRate.should be > 0
  end

  it 'should create and set orders' do
    @exch.stubs(:setOrders).with do |book, threshold|
      book.bids.size.should == 1
      book.asks.size.should == 1

      bid = book.bids[0]
      bid.isBuy.should == true
      bid.size.should == @strat.defaultSize
      bid.price.should == @midpt - @midpt * @fee * (1 + @takeRate)

      ask = book.asks[0]
      ask.isBuy.should == false
      ask.size.should == @strat.defaultSize
      ask.price.should == @midpt + @midpt * @fee * (1 + @takeRate)

      threshold.should be > 0
      threshold.should be < 1
    end

    @strat.iteration
  end

  it 'should adjust bid size correctly' do
    @exch.stubs(:balance).returns({:USD => 150, :BTC => 100})

    @exch.stubs(:setOrders).with do |book, threshold|
      book.bids.size.should == 1
      book.asks.size.should == 1

      bid = book.bids[0]
      ask = book.asks[0]
      bid.size.should == @strat.defaultSize * 2
      ask.size.should == @strat.defaultSize
    end

    @strat.iteration
  end

  it 'should adjust ask size correctly' do
    @exch.stubs(:balance).returns({:USD => 100, :BTC => 150})

    @exch.stubs(:setOrders).with do |book, threshold|
      book.bids.size.should == 1
      book.asks.size.should == 1

      bid = book.bids[0]
      ask = book.asks[0]
      bid.size.should == @strat.defaultSize
      ask.size.should == @strat.defaultSize * 2
    end

    @strat.iteration
  end

end
