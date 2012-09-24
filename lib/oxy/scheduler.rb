require 'thread'

class Scheduler

  def initialize strategy, exchange
    @strategy = strategy
    @exchange = exchange
    @queue = Queue.new
  end

  def run
    while true
      x = @queue.pop
      label = x[:label]
      msg = x[:msg]

      if label == :stream
        @exchange.msg msg
      elsif label == :tick
        @strategy.iteration
      end
    end
  end

  def push label, msg
    @queue.push {
      :label => label,
      :msg => msg
    }
  end

end

