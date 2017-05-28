class Deploy < Sequel::Model
  NOT_RUNNING = 0
  RUNNING = 1
  DONE = 2
  FAILED = 3
end
