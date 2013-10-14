
require "helper"

require 'celluloid'
require 'sidekiq'
require 'sidekiq'
require 'sidekiq/cli'
require 'sidekiq/launcher'
require 'support/sidekiq_mock_fetcher'
require 'support/workers'

require 'micron/test_case/redir_logging'

class TestRecycler < Micron::TestCase

  include Micron::TestCase::RedirLogging
  @@redir_logger = Logging.logger.root

  def setup
  end

  def teardown
    @launcher.stop
    Celluloid.shutdown
  end

  def test_recycler

    opts = {
      :timeout => 0,
    }
    @launcher = Sidekiq::Launcher.new(opts)
    @launcher.run

    # do something..
    MockFetcher.instance.writer.puts "forever"

    sleep 1
    assert_equal 1, ForeverWorker.times_worked

    2.times do
      MockFetcher.instance.writer.puts "hard"
    end
    sleep 1
    assert_equal 2, HardWorker.times_worked

    5.times do
      MockFetcher.instance.writer.puts "hard"
    end

    while HardWorker.times_worked < 7 do
      sleep 0.1
      Thread.pass
    end

    puts "over limit?!"
    sleep 1
    assert_equal 0, @launcher.manager.ready.size, "waiting threads should have been stopped"
    assert_equal 1, @launcher.manager.busy.size, "only one thread still busy (sleeping forever)"
  end

end
