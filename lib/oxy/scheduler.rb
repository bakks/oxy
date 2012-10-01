require 'thread'

class Scheduler
  attr_reader :strategy
  attr_reader :exchange

  def initialize strategy, exchange
    @strategy = strategy
    @exchange = exchange
    @queue = Queue.new
  end

  def start
    pp 'start'
    @thread = Thread.new { run } unless @thread
  end

  def run
    pp 'run'
    while true
      pp 'here'
      return if @stop

      x = @queue.pop
      label = x[:label]
      msg = x[:msg]

      return if @stop

      if label == :stream
        @exchange.msg msg
      elsif label == :tick
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

