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

filename = File.dirname(__FILE__) + '/../../logs/' + Time.now.strftime('oxy.%Y%m%d.%H%M%S.log')
if $env == :production
  file = File.open(filename, 'a')
  file.sync = true
  tee = MultiIO.new(STDOUT, file)
else
  tee = STDOUT
end

$_log = Logger.new(tee)
$_log.level = Logger::INFO

$_log.formatter = proc { |severity, stamp, prog, msg|
  "#{stamp.getutc.strftime('%Y-%m-%dT%H:%M:%S.%6NZ')} #{severity.ljust(8)} #{(prog or '').ljust(12)[0..11]} | #{msg}\n"
}

class Log
  def initialize prog
    @prog = prog
  end

  def info msg
    $_log.info(@prog) { msg }
  end

  def warn msg
    $_log.warn(@prog) { msg }
  end

  def error msg
    $_log.error(@prog) { msg }
  end

  def fatal msg
    $_log.fatal(@prog) { msg }
    raise msg
  end

  def debug msg
    $_log.debug(@prog) { msg }
  end
end

Log.new('logger').info "logger started : #{filename}"
