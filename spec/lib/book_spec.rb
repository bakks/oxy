require 'spec_helper'
require 'oxy'

describe Book do

  it 'should only accept one bid at each price level' do
    t = Time.now
    q1 = Quote.new(true, 5, 1, t - 10)
    q2 = Quote.new(true, 5, 3, t - 5)

    book = Book.new

    book.set(q1).should == nil
    x = book.set(q2)

    book.bids.size.should == 1
    book.bids[0].size.should == 3

    x.start.to_s.should == (t - 10).to_s
    x.finish.to_s.should == (t - 5).to_s
  end

  it 'should only accept one ask at each price level' do
    q1 = Quote.new(false, 5, 1)
    q2 = Quote.new(false, 5, 3)

    book = Book.new

    book.set(q1)
    book.set(q2)

    book.asks.size.should == 1
    book.asks[0].size.should == 3
  end

  it 'should delete bids' do
    t1 = Time.now.getutc - 10
    t2 = Time.now.getutc
    q1 = Quote.new(true, 5, 1, t1)
    q2 = Quote.new(true, 5, 0, t2)

    book = Book.new
    book.set(q1)

    x = book.set(q2)
    book.findBid(5).should == nil
    book.bids.size.should == 0

    x.isBuy.should == true
    x.price.should == 5
    x.size.should == 1
    x.start.should == t1
    x.finish.should == t2
  end

  it 'should delete asks' do
    t1 = Time.now.getutc - 10
    t2 = Time.now.getutc
    q1 = Quote.new(false, 5, 1, t1)
    q2 = Quote.new(false, 5, 0, t2)

    book = Book.new
    book.set(q1)

    x = book.set(q2)
    book.findAsk(5).should == nil
    book.asks.size.should == 0

    x.isBuy.should == false
    x.price.should == 5
    x.size.should == 1
    x.start.should == t1
    x.finish.should == t2
  end

  it 'should order bids correctly' do
    q1 = Quote.new(true, 5, 1)
    q2 = Quote.new(true, 4, 1)
    q3 = Quote.new(true, 3, 1)
    q4 = Quote.new(true, 2, 1)
    q5 = Quote.new(true, 1, 1)

    book = Book.new

    book.set(q2)
    book.set(q5)
    book.set(q1)
    book.set(q3)
    book.set(q4)

    last = 6

    book.bids.size.should == 5

    book.bids.each do |bid|
      bid.size.should == 1
      bid.price.should == last - 1
      last = bid.price
      bid.isBuy.should == true
    end
  end

  it 'should order asks correctly' do
    q1 = Quote.new(false, 1, 1)
    q2 = Quote.new(false, 2, 1)
    q3 = Quote.new(false, 3, 1)
    q4 = Quote.new(false, 4, 1)
    q5 = Quote.new(false, 5, 1)

    book = Book.new

    book.set(q2)
    book.set(q5)
    book.set(q1)
    book.set(q3)
    book.set(q4)

    last = 0

    book.asks.size.should == 5

    book.asks.each do |ask|
      ask.size.should == 1
      ask.price.should == last + 1
      last = ask.price
      ask.isBuy.should == false
    end
  end

  it 'should remove from book' do
    q1 = Quote.new(true, 5, 1)
    q2 = Quote.new(true, 4, 1)
    q3 = Quote.new(true, 3, 1)
    q4 = Quote.new(true, 2, 1)
    q5 = Quote.new(true, 1, 1)

    book = Book.new

    book.set(q2)
    book.set(q5)
    book.set(q1)
    book.set(q3)
    book.set(q4)

    book.bids.size.should == 5
    book.remove q2
    book.bids.size.should == 4
    book.bids[0].should == q1
    book.bids[1].should == q3
    book.remove q2
    book.bids.size.should == 4
  end

end

