module Sinatra
  module Authentication
    def authenticate!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.params == api_token
    end

    def api_token
      ENV['API_TOKEN']
    end
  end
end
