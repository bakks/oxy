require 'spec_helper'
require 'oxy'

describe Persistence do

  before(:all) do 
    @mongodb = Mongo::Connection.new['oxy_' + $env.to_s]
    @mongodb['quotes'].drop
  end

  it 'should persist http requests' do
    stamp = Time.now.getutc
    Persistence::writeHttpRequest '/test', stamp, 200, {'x' => 1}

    cursor = @mongodb['requests'].find({:path => '/test', :timestamp => stamp})
    cursor.has_next?.should == true
    doc = cursor.next

    doc['path'].should == '/test'
    doc['timestamp'].to_s.should == stamp.to_s
    doc['status'].should == 200
    doc['doc']['x'].should == 1
  end

  it 'should persist quotes' do
    id = 'atoehu83o-aoeu'
    q = Quote.new(true, 10, 10, Time.now, nil, id)
    
    r = @mongodb['quotes'].find(:ext_id => id)
    r.to_a.size.should == 0

    Persistence::writeQuote q
    r = @mongodb['quotes'].find(:ext_id => id)
    r.to_a.size.should == 1

    Persistence::writeQuote q
    r = @mongodb['quotes'].find(:ext_id => id)
    r.to_a.size.should == 1
  end
end
