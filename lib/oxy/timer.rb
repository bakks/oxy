require 'thread'

class Timer
  @@log = Log.new 'timer'
  @@label = :tick
  @@interval = 1
  @@thread = nil

  def initialize 
    @@log.info 'running timer'
    @@interval = $config['timer']['interval']
    @@thread = Thread.new { run } unless @@thread
  end

  def self.instance schedule
    @@schedule = schedule
  end

  def run
    while true
      sleep @@interval
      next unless @@schedule
      @@log.info 'timer tick'
      @@schedule.push @@label
    end
  end

  @@instance = Timer.new if $env == :production
  private_class_method :new
end

