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
log.info "starting oxy at #{Time.now.getutc}..."
log.info "environment: #{$env}"

require_relative 'oxy/common'
require_relative 'oxy/book'
require_relative 'oxy/mtgox'
require_relative 'oxy/spreadstrategy'
require_relative 'oxy/depthstrategy'
require_relative 'oxy/persistence'
require_relative 'oxy/stream'
require_relative 'oxy/timer'
require_relative 'oxy/scheduler'

def run
  mtgox = MtGox.new
  strat = SpreadStrategy.new(mtgox)
  scheduler = Scheduler.new strat, mtgox

  timer = Timer.new strat.interval, scheduler
  mtgox.start_stream scheduler

  log = Log.new 'oxy'
  log.info "oxy initialized : #{Time.now.getutc}"

  return scheduler
end

if $env == :production
  scheduler = run
  scheduler.start

  begin
    scheduler.join
  rescue Interrupt
    log.info 'caught interrupt'
    scheduler.exchange.cancelAll
    log.info 'exiting'
  end
end
