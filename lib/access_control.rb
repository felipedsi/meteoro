class AccessControl
  def self.create_user(user_name, max_deploys)
    user = User.new

    user.name = user_name
    user.max_deploys = max_deploys
    user.access_token = SecureRandom.uuid

    user.save
  end

  def self.update_user(user_id, user_name, max_deploys)
    user = User.find(user_id).first

    user.name = user_name
    user.max_deploys = max_deploys

    user.save
  end
end
