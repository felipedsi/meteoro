class Deploy < Sequel::Model
  NOT_RUNNING = 0
  RUNNING = 1
  DONE = 2
  FAILED = 3

  def real_status
    Deploy.status_described[self.status.to_s]
  end

  private

  def self.status_described
    {
      "#{NOT_RUNNING}" => 'not running',
      "#{RUNNING}" => 'running',
      "#{DONE}" => 'done',
      "#{FAILED}" => 'failed',
    }.freeze
  end
end
