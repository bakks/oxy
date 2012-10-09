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
  log = Log.new 'oxy'
  log.info 'starting oxy run'

  log.info 'checking persistence'
  Persistence::check

  mtgox = MtGox.new
  log.info 'initialized mtgox'

  strat = SpreadStrategy.new(mtgox)
  log.info 'initialized strategy'

  scheduler = Scheduler.new strat, mtgox
  log.info 'initialized scheduler'

  timer = Timer.new strat.interval, scheduler
  log.info 'initialized timer'

  mtgox.start_stream scheduler
  log.info 'started stream'

  log.info "oxy initialized : #{Time.now.getutc}"

  return scheduler
end

if $env == :production
  scheduler = run
  scheduler.start
  log.info 'started scheduler, joining thread'

  begin
    scheduler.join
  rescue Interrupt
    log.info 'caught interrupt'
    scheduler.exchange.cancelAll
    log.info 'exiting'
  end
end
