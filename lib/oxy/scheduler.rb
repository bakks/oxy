require 'thread'
require 'timeout'

class Scheduler
  @@log = Log.new 'scheduler'
  attr_reader :strategy
  attr_reader :exchange

  def initialize strategy, exchange
    @@log.info 'initializing scheduler'
    @strategy = strategy
    @exchange = exchange
    @queue = Queue.new
    @stop = false
  end

  def start
    @@log.info 'starting scheduler'
    @thread = Thread.new { run } unless @thread
  end

  def run
    while true
      return if @stop

      x = nil

      while x == nil
        begin
          Timeout::timeout(1) do
            @@log.debug "queue size: #{@queue.size}"
            x = @queue.pop
          end
        rescue Timeout::Error
          return if @stop
        end
      end

      label = x[:label]
      msg = x[:msg]

      return if @stop

      if label == :stream
        @@log.debug 'sending msg to exchange.msg'
        @exchange.msg msg
      elsif label == :tick
        @@log.debug 'running exchange check'
        @exchange.check
        @@log.debug 'running exchange iteration'
        @strategy.iteration
      end
    end
  end

  def stop
    @stop = true
  end

  def join
    @thread.join
  end

  def push label, msg = nil
    @queue.push({
      :label => label,
      :msg => msg
    })
  end

end

