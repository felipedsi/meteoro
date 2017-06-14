class Deployer
  def self.deploy!(image, host, user_id)
    raise NoSlotError unless has_slot?(user_id)
    raise HostInUseError unless host_available?(host)

    app = create_app(host, user_id)
    ship(image, host)

    app
  end

  def self.stop!(app_id, user_id)
    app = App.where(user_id: user_id, id: app_id).first

    raise AppNotFoundError if app.nil?
    raise NotRunningError unless app.status == App::RUNNING

    app.status = App::DONE
    app.save

    MarathonClient.stop_app_by_host(app.host)
  end

  def self.status(app_id, user_id)
    app = App.where(id: app_id, user_id: user_id).select(:status)

    return nil if app.empty?

    app.first.real_status
  end

  def self.all_status(user_id)
    App.where(user_id: user_id).select(:id, :status, :host).map do |app|
      { id: app.id, status: app.real_status, host: app.host }
    end
  end

  private

  def self.has_slot?(user_id)
    current_apps = App.where(user_id: user_id, status: App::RUNNING).count
    max_apps = User.where(id: user_id).select(:max_apps).first.values[:max_apps]

    current_apps < max_apps
  end

  def self.host_available?(host)
    App.where(status: App::RUNNING, host: host).empty?
  end

  def self.create_app(host, user_id)
    app = App.new
    app.user_id = user_id
    app.host = host
    app.status = App::RUNNING
    app.save

    app
  end

  def self.ship(image, host)
    MarathonClient.new(image, host).deploy
  end

  class NoSlotError < StandardError
    def initialize(msg="No remaining slots")
      super(msg)
    end
  end

  class HostInUseError < StandardError
    def initialize(msg="App with this host already running")
      super(msg)
    end
  end

  class NotRunningError < StandardError
    def initialize(msg="App is not running")
      super(msg)
    end
  end

  class AppNotFoundError < StandardError
    def initialize(msg="App does not exist")
      super(msg)
    end
  end
end
