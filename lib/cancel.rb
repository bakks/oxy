require 'mechanize'
require 'sinatra'

USERNAME = 'tourbillon'
PASSWORD = 'Q3eGPwULhPtn'
DOMAIN = 'https://mtgox.com'

set :port, 14555

@@token = ''
@@agent = nil


def login
  @@agent = Mechanize.new
  @@agent.post(DOMAIN + '/code/login.json', {:username => USERNAME, :password => PASSWORD})

  page = @@agent.get(DOMAIN)
  @@token = /var token = "(\w+)"/.match(page.body)[1]
  raise 'no token found' unless @@token

  puts 'token: ' + @@token
end

login

get '/' do
  'online'
end

post '/cancel' do
  return 'no oid' unless params[:oid]

  args = {:token => @@token, :oid => params[:oid]}
  x = @@agent.post(DOMAIN + '/code/cancelOrder.php', args)
  x.body
end

