require 'spec_helper'
require 'webmock/rspec'
require 'oxy'

describe Scheduler do

  it 'should run' do
    testmsg = '{foo:0}'

    exch = mock('MtGox')
    exch.stubs(:msg).times(2).with do |msg|
      msg.should == testmsg
    end
    exch.stubs(:balance).returns({:USD => 10, :BTC => 10}).twice
    exch.stubs(:start_stream).once
    exch.stubs(:fetchOrders).once
    exch.stubs(:cancelAll).once
    exch.stubs(:fetchAccounts).once
    exch.stubs(:value).returns(100).once
    exch.stubs(:midpoint).returns(10).once
    MtGox.stubs(:new).returns(exch)

    scheduler = run

    scheduler.strategy.stubs(:iteration).times(2)

    scheduler.start
    scheduler.push :tick
    scheduler.push :stream, testmsg
    scheduler.push :tick
    scheduler.push :stream, testmsg
    sleep 1
    scheduler.stop
    scheduler.join
  end

end
