$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'helpers'))

require 'sinatra'
require 'rack'
require 'authentication'

class TestManager < Sinatra::Application
  include Sinatra::Authentication

  get '/' do
  	authenticate!
    return 200
  end
end
