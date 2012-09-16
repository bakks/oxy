require 'helper'
require 'oxy'

describe Book do

  it 'should order bids correctly' do
    q1 = Quote.new(true, 5, 1)
    q2 = Quote.new(true, 4, 1)
    q3 = Quote.new(true, 3, 1)
    q4 = Quote.new(true, 2, 1)
    q5 = Quote.new(true, 1, 1)

    book = Book.new

    book.add(q2)
    book.add(q5)
    book.add(q1)
    book.add(q3)
    book.add(q4)

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

    book.add(q2)
    book.add(q5)
    book.add(q1)
    book.add(q3)
    book.add(q4)

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

    book.add(q2)
    book.add(q5)
    book.add(q1)
    book.add(q3)
    book.add(q4)

    book.bids.size.should == 5
    book.remove q2
    book.bids.size.should == 4
    book.bids[0].should == q1
    book.bids[1].should == q3
    book.remove q2
    book.bids.size.should == 4
  end

end

