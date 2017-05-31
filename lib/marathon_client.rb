require 'marathon'

class MarathonClient
  attr_reader :image, :host

  def initialize(image, host)
    @image = image
    @host = host
  end

  def deploy
    # Marathon::App.new(app_config).start!(true)
  end

  private

  def app_config
    {
      "id" => "/web",
      "cmd" => nil,
      "cpus" => 0.2,
      "mem" => 1024,
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
