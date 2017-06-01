require 'marathon'

class MarathonClient
  attr_reader :image, :host

  def initialize(image, host)
    @image = image
    @host = host

    Marathon.url = marathon_url
  end

  def deploy
    Marathon::App.new(app_config).start!(true)
  end

  def self.stop_app_by_host(host)
    Marathon::App.delete("web-#{host.downcase}")
  end

  private

  def marathon_url
    ENV["MARATHON_URL"]
  end

  def app_config
    {
      "id" => "/web-#{host.downcase}",
      "cmd" => nil,
      "cpus" => 0.1,
      "mem" => 64,
      "disk" => 0,
      "instances" => 1,
      "acceptedResourceRoles" => [
        "slave_public",
        "*"
      ],
      "container" => {
        "type" => "DOCKER",
        "volumes" => [],
        "docker" => {
          "image" => image,
          "network" => "BRIDGE",
          "portMappings" => [
            {
              "containerPort" => 80,
              "hostPort" => 0,
              "servicePort" => 10101,
              "protocol" => "tcp",
              "labels" => {}
            }
          ],
          "privileged" => false,
          "parameters" => [],
          "forcePullImage" => true
        }
      },
      "env" => {
      },
      "healthChecks" => [
        {
          "path" => "/",
          "protocol" => "HTTP",
          "portIndex" => 0,
          "gracePeriodSeconds" => 300,
          "intervalSeconds" => 60,
          "timeoutSeconds" => 10,
          "maxConsecutiveFailures" => 3,
          "ignoreHttp1xx" => false
        }
      ],
      "labels" => {
        "HAPROXY_GROUP" => "external,internal",
        "HAPROXY_0_VHOST" => host
      }
    }
  end
end
