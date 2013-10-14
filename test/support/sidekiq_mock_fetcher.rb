
require "thread"
require "securerandom"

class MockFetcher

  UnitOfWork = Struct.new(:queue, :message) do
    def acknowledge
    end
    def queue_name
      "jobs"
    end
    def requeue
    end
  end

  attr_accessor :reader, :writer

  def self.instance(opts=nil)
    if @inst.nil? then
      @inst = self.allocate
      @inst.setup
    end
    @inst
  end

  class << self
    alias_method :new, :instance
  end

  def setup
    @reader, @writer = IO.pipe
    @mutex = Mutex.new
  end

  def retrieve_work
    @mutex.synchronize {
      begin
        return internal_fetch()
      rescue Exception => ex
        $stderr.puts ex
      end
    }
  end

  def self.bulk_requeue(*args)
    # noop
  end


  private

  def internal_fetch

    data = case reader.readline.strip
    when "forever"
      {:jid => SecureRandom.hex(4),
       :class => ForeverWorker.name, :args => []}

    when "hard"
      {:jid => SecureRandom.hex(4),
       :class => HardWorker.name, :args => ["test"]}
    end

    return UnitOfWork.new("foobar", MultiJson.dump(data))
  end

end

module Sidekiq
  class Fetcher
    def self.strategy
      MockFetcher
    end
  end
end

Sidekiq::Logging.logger = Logging.logger[Sidekiq]

module Sidekiq
  module Logging
    def self.with_context(msg)
      begin
        ::Logging.mdc["sidekiq"] = msg
        yield
      ensure
        ::Logging.mdc["sidekiq"] = nil
      end
    end
  end
end
