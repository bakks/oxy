require 'thread'

class Timer
  @@label = :tick

  def initialize interval, schedule
    @interval = interval
    @schedule = schedule
    @thread = Thread.new { run } unless @thread
  end

  def run
    while true
      sleep @interval
      @schedule.push @@label
    end
  end

end

