class Deployer
  def self.deploy!(image, host, user_id)
    raise NoSlotError unless has_slot?(user_id)

    app = create_app(host, user_id)
    ship(image, host)

    app
  end

  def self.stop!(app_id)
    app = App.where(id: app_id).first

    raise AppNotFoundError if app.nil?
    raise NotRunningError unless app.status == App::RUNNING

    app.status = App::DONE
    app.save

    MarathonClient.stop_app_by_host(app.host)
  end

  def self.status(app_id)
    app = App.where(id: app_id).select(:status)

    return nil if app.empty?

    app.first.real_status
  end

  def self.all_status
    App.select(:id, :status, :host).map do |app|
      { id: app.id, status: app.real_status, host: app.host }
    end
  end

  private

  def self.has_slot?(user_id)
    current_apps = App.where(status: Appp::RUNNING).count
    max_apps = User.where(id: user_id).select(:max_apps).first.values[:max_apps]

    current_apps < max_apps
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
