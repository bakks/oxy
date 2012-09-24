require 'thread'
require 'eventmachine'
require 'em-websocket-client'
require 'json'
require 'pp'

class Stream
  @@label = :stream
  @@log = Log.new(@@label.to_s)

  def initialize address, schedule
    raise 'need scheduler' unless schedule.is_a? Scheduler
    @address = address
    @schedule = schedule
  end

  def start
    @thread = Thread.new { run } unless @thread
  end

  def run
    @@log.info "connecting to streaming at #{@address} ..."

    EM.run do
      conn = EventMachine::WebSocketClient.connect(@address)

      conn.callback do
        @@log.info 'websocket connected'
      end

      conn.errback do |e|
        @@log.error "got error back: #{e}"
      end

      conn.stream do |msg|
        pp msg
        begin
          @schedule.push @@label, JSON(msg)
        rescue Exception => e
          @@log.error "problem pushing msg to schedule: #{msg}"
        end
      end

      conn.disconnect do
        @@log.warn 'got disconnect'
        EM::stop_event_loop
      end
    end
  end

  def join
    @thread.join
  end
end

