require 'thread'
require 'eventmachine'
require 'em-websocket-client'
require 'json'
require 'pp'

MTGOX_TRADES = 'dbf1dee9-4f2e-4a08-8cb7-748919a71b21'
MTGOX_TICKER = 'd5f06780-30a8-4a48-a2f8-7ed181b4a13f'
MTGOX_DEPTH  = '24e67e0d-1cad-4cc0-9e7a-f8523ef460fe'
MTGOX_STREAM = 'ws://websocket.mtgox.com/mtgox?Currency=USD'

class MtGoxStream
  @@log = Log.new('stream')

  def initialize queue
    raise 'need threaded queue' unless queue.is_a? Queue
    @queue = queue
    @thread = Thread.new { run }
  end

  def run
    @@log.info "connecting to MtGox streaming at #{MTGOX_STREAM}"

    i = 0
    EM.run do
      conn = EventMachine::WebSocketClient.connect(MTGOX_STREAM)

      conn.callback do
        @@log.info 'MtGox websocket connected'
      end

      conn.errback do |e|
        @@log.warn "got error back: #{e}"
      end

      conn.stream do |msg|
        puts "<#{msg}>"
        i += 1

        if i == 10
          puts 'sending'
          pp conn.send_msg(unsub(MTGOX_TICKER))
          puts 'sent'
        end
      end

      conn.disconnect do
        @log.info 'got disconnect'
        EM::stop_event_loop
      end
    end
  end

  def join
    @thread.join
  end

  def op
    x = {
      :op => 'mtgox.subscribe',
      :type => 'ticker'
    }
    x.to_json
  end

  def unsub x
    {
      :op => 'unsubscribe',
      :channel => x
    }.to_json
  end
end

