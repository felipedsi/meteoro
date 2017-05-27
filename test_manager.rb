$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'helpers'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'models'))

require 'sinatra'
require 'sinatra/sequel'
require 'pg'
require 'rack'
require 'authentication'

class TestManager < Sinatra::Application
  include Sinatra::Authentication

   configure do
      set :database, ENV['DATABASE_URL']
      require 'deploy'
      require 'user'
   end

  get '/' do
  	authenticate!
    return 200
  end

  # Create user
  post '/user' do
    authenticate!

    return 200
  end


  # 1. Deploy app to Marathon
  # 2. Map host to new app
  # { "host": "meteoro.foo.bar", "image": "" }
  post '/deploy' do
    image = params[:image]

    "xunda #{image}"
  end
end
