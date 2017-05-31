class Deployer
  def self.deploy!(image, host, user_id)
    raise NoSlotError unless has_slot?(user_id)

    deploy = create_deploy(host, user_id)
    ship(image, host)

    deploy
  end

  def self.stop!(deploy_id)
    deploy = Deploy.where(id: deploy_id).first

    raise DeployNotFoundError if deploy.nil?
    raise NotRunningError unless deploy.status == Deploy::RUNNING

    deploy.status = Deploy::DONE
    deploy.save

    MarathonClient.stop_app_by_host(deploy.host)
  end

  def self.status(deploy_id)
    deploy = Deploy.where(id: deploy_id).select(:status)

    return nil if deploy.empty?

    deploy.first.real_status
  end

  def self.all_status
    Deploy.select(:id, :status, :host).map do |deploy|
      { id: deploy.id, status: deploy.real_status, host: deploy.host }
    end
  end

  private

  def self.has_slot?(user_id)
    current_deploys = Deploy.where(status: Deploy::RUNNING).count
    max_deploys = User.where(id: user_id).select(:max_deploys).first.values[:max_deploys]

    current_deploys < max_deploys
  end

  def self.create_deploy(host, user_id)
    deploy = Deploy.new
    deploy.user_id = user_id
    deploy.host = host
    deploy.status = Deploy::RUNNING
    deploy.save

    deploy
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

  class DeployNotFoundError < StandardError
    def initialize(msg="Deploy does not exist")
      super(msg)
    end
  end
end
