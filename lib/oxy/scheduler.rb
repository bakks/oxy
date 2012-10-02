require 'thread'
require 'timeout'

class Scheduler
  attr_reader :strategy
  attr_reader :exchange

  def initialize strategy, exchange
    @strategy = strategy
    @exchange = exchange
    @queue = Queue.new
    @stop = false
  end

  def start
    @thread = Thread.new { run } unless @thread
  end

  def run
    while true
      return if @stop

      x = nil

      while x == nil
        begin
          Timeout::timeout(1) do
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

