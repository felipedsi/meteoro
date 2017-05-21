$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'../helpers'))

require 'sinatra'
require 'rack'

class TestManager < Sinatra::Application
  get '/' do
    return 200
  end
end
