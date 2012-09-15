require 'helper'
require 'common'

describe Quote do

  it 'should initialize' do
    q = Quote.new true, 1.1, 2.2
    q.isBuy.should == true
    q.price.should == 1.1
    q.size.should == 2.2
  end

  it 'should handle empty init' do
    Quote.new
  end

end
