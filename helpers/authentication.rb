module Sinatra
  module Authentication
    attr_reader :current_user  

    def authenticate!
      deny unless api_token_authorized?
    end

    def authenticate_access_token!
      user = User.where(access_token: access_token).first

      return deny if user.nil?

      @current_user = user
    end

    private

    def deny
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def api_token_authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.params == api_token
    end

    def api_token
      ENV['API_TOKEN']
    end

    def access_token
      payload['access_token']
    end
  end
end
