require 'mongo'

class Persistence

  def self.db
    $mongodb = Mongo::Connection.new('localhost', 27017)['oxy_' + $env.to_s]
  end

  def self.writeHttpRequest path, timestamp, status, document
    arg = {
      :path => path,
      :timestamp => timestamp.getutc,
      :status => status.to_i,
      :doc => document
    }

    db['requests'].insert(arg)
  end

end
