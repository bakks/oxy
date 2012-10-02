$env = :development
e = ENV['OXY_ENVIRONMENT']

if e == 'production'
  $env = :production
elsif e == 'testing'
  $env = :testing
elsif e == 'integration'
  $env = :integration
end

require_relative 'oxy/logger'

log = Log.new 'oxy'
log.info 'starting oxy...'
log.info "environment: #{$env}"

require_relative 'oxy/common'
require_relative 'oxy/book'
require_relative 'oxy/mtgox'
require_relative 'oxy/strategy'
require_relative 'oxy/persistence'
require_relative 'oxy/stream'
require_relative 'oxy/timer'
require_relative 'oxy/scheduler'

def run
  mtgox = MtGox.new
  strat = Strategy.new(mtgox)
  scheduler = Scheduler.new strat, mtgox

  timer = Timer.new strat.interval, scheduler
  mtgox.start_stream scheduler

  log = Log.new 'oxy'
  log.info "oxy initialized : #{Time.now.getutc}"

  return scheduler
end

run.start if $env == :production

