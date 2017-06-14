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
require 'app'
require 'user'

class TestManager < Sinatra::Application
  include Sinatra::Authentication

  helpers do
    def access_token?
      access_token == 'true'
    end

    def access_token
      params['access_token'] || payload['access_token']
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
      halt 404, generate_error("RESOURCE_NOT_FOUND", "#{resource} not found")
    end

    def no_remaining_slots
      return 400, generate_error("NO_REMAINING_SLOTS", "No remaining slots to deploy. Maximum is #{current_user.max_apps}")
    end

    def host_in_use(host)
      return 400, generate_error("HOST_IN_USE", "There is already an app running with provided host: #{host}")
    end

    def app_not_running(app_id)
      return 400, generate_error("APP_NOT_RUNNING", "App for deploy #{app_id} is not running")
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

    user_name = validate_param(payload['name'], 'name')
    max_apps = validate_param(payload['max_apps'], 'max_apps')

    user = AccessControl.create_user(user_name, max_apps)

    "#{user.values.to_json}"
  end

  put '/users/:id' do
    authenticate!

    user_id = validate_param(params[:id].to_i, 'id')
    user_name = payload['name']
    max_apps = payload['max_apps']

    user = AccessControl.update_user(user_id, user_name, max_apps)

    "#{user.values.to_json}"
  end

  get '/apps/:id' do
    authenticate_access_token!

    status = Deployer.status(params[:id].to_i)

    return resource_not_found('app') if status.nil?

    { id: params[:id], status: status }.to_json
  end

  get '/apps' do
    authenticate_access_token!

    app_status = Deployer.all_status(current_user.id)

    { apps: app_status }.to_json
  end

  post '/apps' do
    authenticate_access_token!

    image = payload["image"]
    host = payload["host"]

    return missing_params('image') if image.nil?
    return missing_params('host') if host.nil?

    begin
      app = Deployer.deploy!(image, host, current_user.id)

      app.values.tap { |v| v[:status] = app.real_status }.to_json
    rescue Deployer::NoSlotError
      no_remaining_slots
    rescue Deployer::HostInUseError
      host_in_use(host)
    end
  end

  delete '/apps/:id' do
    authenticate_access_token!

    app_id = params[:id]

    begin
      Deployer.stop!(app_id)
    rescue Deployer::NotRunningError
      return app_not_running(deploy_id)
    rescue Deployer::AppNotFoundError
      return resource_not_found("app")
    end

    return 200, { message: "success" }.to_json
  end
end
