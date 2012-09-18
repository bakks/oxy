require 'socket'
require 'eventmachine'
require 'em-websocket-client'
require 'json'
require 'pp'

MTGOX_TRADES = 'dbf1dee9-4f2e-4a08-8cb7-748919a71b21'
MTGOX_TICKER = 'd5f06780-30a8-4a48-a2f8-7ed181b4a13f'
MTGOX_DEPTH  = '24e67e0d-1cad-4cc0-9e7a-f8523ef460fe'
MTGOX_STREAM = 'ws://websocket.mtgox.com/mtgox?Currency=USD'

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

class WebSocket

  def initialize(url, params = {})
    @hs ||= LibWebSocket::OpeningHandshake::Client.new(:url => url, :version => params[:version])
    @frame ||= LibWebSocket::Frame.new

    @socket = TCPSocket.new(@hs.url.host, @hs.url.port || 80)

    @socket.write(@hs.to_s)
    @socket.flush

    loop do
      data = @socket.getc
      next if data.nil?

      result = @hs.parse(data.chr)

      raise @hs.error unless result

      if @hs.done?
        @handshaked = true
        break
      end
    end
  end

  def send(data)
    raise "no handshake!" unless @handshaked

    data = @frame.new(data).to_s
    @socket.write data
    @socket.flush
  end

  def receive
    raise "no handshake!" unless @handshaked

    data = @socket.gets("\xff")
    @frame.append(data)

    messages = []
    while message = @frame.next
      messages << message
    end
    messages
  end

  def socket
    @socket
  end

  def close
    @socket.close
  end

end

client = WebSocket.new(MTGOX_STREAM)

puts client.receive
puts client.receive
puts client.receive

puts 'sending'
#client.send(unsub(MTGOX_TRADES))
client.send(unsub(MTGOX_TICKER))
#client.send(unsub(MTGOX_DEPTH))
puts 'sent'

while true
  puts client.receive
end


puts 'blah'

exit
EventMachine.run {
  http = EventMachine::WebSocketClient.connect(MTGOX_STREAM)

  http.errback do |x|
    puts "oops: " + x
  end

  http.callback do
    puts 'callback'
    puts http.send_data(op)
  end

  http.stream do |msg|
    puts "Recieved: #{msg}"
  end

  http.disconnect do 
    puts 'disconnect'
  end
}

