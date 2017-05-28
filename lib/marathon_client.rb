require 'marathon'

class MarathonClient
  attr_reader :image

  def initialize(image)
    @image = image

    Marathon.url = marathon_url
  end

  def deploy

  end

  private

  def marathon_url
    ENV['MARATHON_URL']
  end

  def app_config
    {

    }
  end
end
