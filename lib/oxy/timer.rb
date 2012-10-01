require 'thread'

class Timer
  @@label = :tick

  def initialize interval, schedule
    @interval = interval
    @schedule = schedule
  end

  def start
    @thread = Thread.new { run } unless @thread
  end

  def run
    sleep @interval
    schedule.push @@label
  end

end

