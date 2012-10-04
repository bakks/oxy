require 'pty'

def runcmd cmd
  begin
    PTY.spawn( cmd ) do |r, w, pid|
      begin
        r.each { |line| print line }
      rescue Errno::EIO
      end
    end
  rescue PTY::ChildExited => e
    puts "The child process exited!"
  end
end

task :test do
  runcmd 'rspec --tag ~integration'
end

task :integration do
  ENV['OXY_ENVIRONMENT'] = 'integration'
  runcmd 'rspec --tag integration -P **/*_integration_spec.rb'
end

task :run do
  Dir.chdir 'lib'
  ENV['OXY_ENVIRONMENT'] = 'production'
  require './oxy'
end

task :stream do
  require_relative 'lib/oxy'
  
  class Sched
    def push label, msg
      puts msg
    end
  end

  stream = Stream.new(MTGOX_STREAM, Sched.new)
  stream.run
end

