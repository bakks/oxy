$env = :development
e = ENV['OXY_ENVIRONMENT']

if e == 'production'
  $env = :production
elsif e == 'testing'
  $env = :testing
elsif e == 'integration'
  $env = :integration
end

require 'oxy/logger'

log = Log.new 'oxy'

log.info 'starting oxy...'

require 'oxy/common'
require 'oxy/book'
require 'oxy/mtgox'
require 'oxy/strategy'

log.info "oxy initialized : #{Time.now.getutc}"

