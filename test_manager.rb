$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'helpers'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'models'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'initializers'))
$:.unshift(File.expand_path File.join(File.dirname(__FILE__),'lib'))

require 'sinatra'
require 'database'
require 'rack'
require 'authentication'
require 'deployer'
require 'access_control'
require 'marathon_client'
require 'deploy'
require 'user'

class TestManager < Sinatra::Application
  include Sinatra::Authentication

  helpers do
    def access_token?
      params[:access_token] == 'true'
    end

    def missing_params(param)
      return 422, generate_error("MISSING_PARAM", "Missing param: #{param}")
    end

    def payload 
      @payload ||= JSON.parse(request.body.read)
    end

    def validate_param(param, name)
      return param unless param.nil?

      missing_params(name)
    end

    def resource_not_found(resource)
      halt 404, generate_error("RESOURCE_NOT_FOUND", "#{resource} not found\n")
    end

    def no_remaining_slots
      return 400, generate_error("NO_REMAINING_SLOTS", "No remaining slots to deploy. Maximum is #{current_user.max_deploys}")
    end

    def generate_error(type, msg)
      { errors: { type: type, message: msg } }.to_json
    end
  end

  get '/ping' do
    return 200, { ping: 'pong' }.to_json
  end

  get '/users' do
    authenticate!

    users = User.all_to_hash(access_token?)

    "#{users.to_json}"
  end

  post '/users' do
    authenticate!

    user_name = payload['name']
    max_deploys = payload['max_deploys']

    AccessControl.create_user(user_name, max_deploys)
  end

  put '/users/:id' do
    authenticate!

    user_id = validate_param(params[:id].to_i, 'id')
    user_name = validate_param(payload['name'], 'name')
    max_deploys = validate_param(payload['max_deploys'], 'max_deploys')

    AccessControl.update_user(user_id, user_name, max_deploys)
  end

  get '/deploys/:id' do
    authenticate_access_token!

    status = Deployer.status(params[:id].to_i)

    return resource_not_found('deploy') if status.nil?

    { id: params[:id], status: status }.to_json
  end

  get '/deploys' do
    authenticate_access_token!

    deploy_status = Deployer.all_status

    { deploys: deploy_status }.to_json
  end

  post '/deploys' do
    authenticate_access_token!

    image = payload["image"]
    host = payload["host"]

    return missing_params('image') if image.nil?
    return missing_params('host') if host.nil?

    begin
      deploy = Deployer.deploy!(image, host, current_user.id)

      deploy.values.tap { |v| v[:status] = deploy.real_status }.to_json
    rescue Deployer::NoSlotError
      no_remaining_slots
    end
  end
end
