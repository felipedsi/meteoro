class Deployer
  def self.deploy!(image, user_id)
    raise NoSlotError unless has_slot?(user_id)

    deploy = create_deploy(user_id)
    ship(image)

    deploy
  end

  def self.status(deploy_id)
    deploy = Deploy.where(id: deploy_id).select(:status)

    return nil if deploy.empty?

    deploy.first.real_status
  end

  def self.all_status
    Deploy.select(:id, :status).map do |deploy|
      { id: deploy.id, status: deploy.real_status }
    end
  end

  private

  def self.has_slot?(user_id)
    current_deploys = Deploy.where(status: Deploy::RUNNING).count
    max_deploys = User.where(id: user_id).select(:max_deploys).first.values[:max_deploys]

    current_deploys < max_deploys
  end

  def self.create_deploy(user_id)
    deploy = Deploy.new
    deploy.user_id = user_id
    deploy.status = Deploy::RUNNING
    deploy.save

    deploy
  end

  def self.ship(image)
    # MarathonClient.new(image).deploy
  end

  class NoSlotError < StandardError
    def initialize(msg="No remaining slots")
      super(msg)
    end
  end
end
