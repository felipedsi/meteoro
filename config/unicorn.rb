require 'dotenv/load'
require 'sequel'

worker_processes Integer(ENV['WEB_CONCURRENCY'].to_i || 5)
timeout Integer(ENV['WEB_TIMEOUT'].to_i || 30000)
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    Process.kill 'QUIT', Process.pid
  end

  if defined?(Sequel::Model)
    DB.disconnect
  end
end
