$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'../lib'))

require 'sinatra'
require 'rack'

class Deployer < Sinatra::Base
  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.params == api_token
    end

    def api_token
      ENV['API_TOKEN']
    end
  end

  get '/' do
      return 200
  end
end
