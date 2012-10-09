require 'thread'

class Timer
  @@log = Log.new 'timer'
  @@label = :tick

  def initialize interval, schedule
    @@log.info 'running timer'
    @interval = interval
    @schedule = schedule
    @thread = Thread.new { run } unless @thread
  end

  def run
    while true
      sleep @interval
      @@log.info 'timer tick'
      @schedule.push @@label
    end
  end

end

