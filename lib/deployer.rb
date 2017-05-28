class Deployer
	def self.deploy!(image, user_id)
    raise NoSlotError unless has_slot?(user_id)

    create_deploy(user_id)
    ship(image)
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
  end

  def self.ship(image)
    MarathonClient.new.deploy(image)
  end

  class NoSlotError < StandardError
    def initialize(msg="No remaining slots")
      super(msg)
    end
  end
end
