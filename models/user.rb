class User < Sequel::Model
  def self.all_to_hash(with_access_token)
    users = User.all.map(&:values)

    return users if with_access_token

    remove_access_token(users)
  end

  private

  def self.remove_access_token(users)
    users.map do |user|
      user.tap { |u| u.delete(:access_token) }
    end
  end
end
