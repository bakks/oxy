$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'rspec'
require 'mocha_standalone'

RSpec.configure do |config|
  config.mock_with :mocha
  config.fail_fast = true
end

def asset filename
  IO.read('spec/asset/' + filename)
end


