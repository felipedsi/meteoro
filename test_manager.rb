$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'helpers'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'models'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'initializers'))

require 'sinatra'
require 'database'
require 'rack'
require 'authentication'
require 'deploy'
require 'user'

class TestManager < Sinatra::Application
  include Sinatra::Authentication

  helpers do
    def access_token?
      params[:access_token] == 'true'
    end
  end

  get '/' do
    return 200
  end

  # (flag access_token) - return users list (with user_id)
  # - if access_token=true -> return access_token
  get '/users' do
    authenticate!

    users = User.all_to_hash(access_token?)

    "#{users.to_json}"
  end

  post '/users' do
    authenticate!

    user_name = params[:name]
    max_deploys = params[:max_deploys]

    AccessControl.create_user(user_name, max_deploys)
  end

  put '/users/:id' do
    authenticate!

    user_id = params[:user_id]
    user_name = params[:name]
    max_deploys = params[:max_deploys]

    AccessControl.update_user(user_id, user_name, max_deploys)
  end

  # (access token) - return id do deploy
  # - args:
  #   - docker_image (with or without tag)
  # - Validar se ele tem limite disponível
  post '/deploys' do
    authenticate_access_token!

    image = params[:image]

    Deployer.deploy!(image, current_user.id)
  end

  # (access token) - status do deploy pelo id
  get '/deploys/:id' do
    authenticate_access_token!
  end

  # (access token) - ids dos deploys com status, com max_deploys 
  get '/deploys' do
    authenticate_access_token!
  end
end
