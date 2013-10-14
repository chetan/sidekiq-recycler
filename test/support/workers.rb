
require "sidekiq"
require "sidekiq/recycler"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Recycler, :mem_limit => 100_000, :hard_limit_sec => 30
  end
end

class ForeverWorker
  @@worked = 0
  include Sidekiq::Worker
  def perform()
    @@worked += 1
    puts "working forever!"
    while true
      sleep 1
    end
  end

  def self.times_worked
    @@worked
  end
end

class HardWorker
  @@worked = 0
  @@foo = []
  include Sidekiq::Worker
  def perform(msg)
    @@foo << "hello world" * (4**10)
    puts "perform.."
    @@worked += 1
  end

  def self.times_worked
    @@worked
  end
end
