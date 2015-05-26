
module Sidekiq
  class Recycler

    # used to avoid race conditions when recycling
    @@mutex = Mutex.new

    # avoid extra spam after hard limit reached
    @@recycled = false

    def initialize(opts={})
      @mem_limit      = opts[:mem_limit] || 300_000 # default is 300mb
      @soft_limit_sec = opts[:soft_limit_sec] || 300 # default to 300 sec
      @hard_limit_sec = opts[:hard_limit_sec] || 600 # default to 600 sec
    end

    def call(worker, job, queue)
      begin
        yield

      ensure
        # check mem usage here
        rss = `ps -o rss= -p #{$$}`.to_i
        if rss > @mem_limit then

          # handle race conditions with many jobs/threads completing
          # at the same time
          return if !@@mutex.try_lock or @@recycled
          @@recycled = true

          Sidekiq.logger.warn "Recycler threshold reached: #{rss} > #{@mem_limit}"
          Sidekiq.logger.warn "Attempting to stop gracefully"

          soft_limit_sec = @soft_limit_sec
          hard_limit_sec = @hard_limit_sec
          launcher = nil

          Thread.new do
            Celluloid::Actor.all.each do |actor|
              # tell sidekiq to exit gracefully
              # stops accepting new work and kills all waiting ("ready") threads
              if actor.kind_of? Sidekiq::Launcher then
                launcher = actor
                Thread.new do
                  actor.manager.async.stop
                end
              end
            end
          end

          Thread.new do
            # wait until all threads have exited
            while true do
              sleep 1
              next if launcher.nil?
              if launcher.manager.ready.empty? and launcher.manager.busy.empty? then
                Sidekiq.logger.info "All threads stopped; exiting now!"
                exit
              end
            end
          end

          Thread.new do
            # wait for soft limit sec then kill -TERM
            sleep soft_limit_sec
            Sidekiq.logger.warn "Soft limit of #{soft_limit_sec}sec reached; sending TERM signal"
            if !launcher.nil? then
              launcher.stop
            else
              Process.kill("TERM", $$)
            end
          end

          Thread.new do
            # wait for hard limit sec then exit(0)
            sleep hard_limit_sec
            Sidekiq.logger.warn "Hard limit of #{hard_limit_sec}sec reached; exiting forcely now!"
            exit
          end
        end
      end
    end

  end
end
