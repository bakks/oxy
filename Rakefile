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
  runcmd 'rspec --tag integration -P **/*_integration_spec.rb'
end

task :run do
  Dir.chdir 'lib'
  ENV['OXY_ENVIRONMENT'] = 'production'
  require './oxy'
end
