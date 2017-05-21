require 'sequel'

worker_processes 5
timeout 30000
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|
  Sequel::Model.db = Sequel.connect(ENV['DATABASE_URL']) if ENV['DATABASE_URL']
end

