require 'helper'
require 'oxy'

describe MtGox do

  it 'should make requests' do
    mtgox = MtGox.new
    mtgox.fetchAccounts()
    mtgox.fee.should == 0.006
  end

end
