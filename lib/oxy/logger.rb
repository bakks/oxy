require 'logger'
require 'time'

class MultiIO
  def initialize(*targets)
     @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

filename = Time.now.strftime('../logs/oxy.%Y%m%d.%H%M%S.log')
if $env == :production
  tee = MultiIO.new(STDOUT, File.open(filename, 'a'))
else
  tee = STDOUT
end

$log = Logger.new(tee)
$log.level = Logger::INFO

$log.formatter = proc { |severity, stamp, prog, msg|
  "#{severity.ljust(7)} #{stamp.getutc.strftime('%H:%M:%S.%L')} #{(prog or '').ljust(12)[0..11]} | #{msg}\n"
}

class Log
  def initialize prog
    @prog = prog
  end

  def info msg
    $log.info(@prog) { msg }
  end

  def warn msg
    $log.warn(@prog) { msg }
  end

  def error msg
    $log.error(@prog) { msg }
  end

  def fatal msg
    $log.fatal(@prog) { msg }
    exit
  end

  def debug msg
    $log.debug(@prog) { msg }
  end
end

Log.new('logger').info "logger started : #{filename}"
