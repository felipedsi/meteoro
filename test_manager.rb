$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'helpers'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'models'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'config'))

require 'sinatra'
require 'database'
require 'rack'
require 'authentication'
require 'deploy'
require 'user'

class TestManager < Sinatra::Application
  include Sinatra::Authentication

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
