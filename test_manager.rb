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
      params[:access_token]
    end
  end

  get '/' do
    return 200
  end

  # (flag access_token) - return users list (with user_id)
  # - if access_token=true -> return access_token
  get '/users' do
    authenticate!


  end

  # return access token - acesso restrito pelo API_TOKEN
  post '/users' do
    authenticate!

    user_id = params[:user_id]
    user_name = params[:name]
    max_deploys = params[:max_deploys]

    AccessControl.upsert_user(user_id, user_name, max_deploys)
  end

  #  (flag access_token) - update info
  # - if access_token=true -> return access_token
  put '/users/:id' do
  end

  # (access token) - return id do deploy
  # - Validar se ele tem limite disponível
  post '/deploys' do
  end

  # (access token) - status do deploy pelo id
  get '/deploys/:id' do
  end

  # (access token) - ids dos deploys com status, com max_deploys 
  get '/deploys' do
  end
end
