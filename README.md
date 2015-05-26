# Sidekiq Recycler
Gracefully recycle sidekiq processes that use too much memory

sidekiq-recycler is a simple middleware which checks the process's RSS usage on
the completion of each job. When the usage surpasses a predefined limit, the process
will gracefully terminate. If any jobs are still running beyond a further time threshold,
they will be killed and requeued.

sidekiq-recycler is best used with a process monitor like god, monit, upstart,
etc, so that your sidekick process will be properly restarted after it quits.


## Quickstart

```
$ gem install sidekiq-recycler
```

```ruby
# Add the middleware
require "sidekiq"
require "sidekiq/recycler"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Recycler, :mem_limit => 300_000, :soft_limit_sec => 300, :hard_limit_sec => 600
  end
end
```


## Configuration

Two options are exposed by the middleware:

 * mem_limit: RSS usage limit, in megabytes
 * soft_limit_sec: time in seconds to wait for jobs to finish, after graceful shutdown initiated. Send TERM signal
 * hard_limit_sec: time in seconds to wait for jobs to finish, after graceful shutdown initiated. Exit forcely

## Kick the tires

You can see the recycler in action by doing the following (requires redis server):

```bash
git clone https://github.com/chetan/sidekiq-recycler.git
cd sidekiq-recycler
bundle exec sidekiq --queue="*" --require ./test/support/workers.rb
```

And in another terminal:

```bash
bundle exec test/support/create_jobs.rb
```

This will spawn some jobs that eat lots of memory and a single jobs which runs forever.
You should see messages like the following printed on your console:

```
2013-10-14T18:04:19Z WARN: Recycler threshold reached: 102848 > 100000
2013-10-14T18:04:19Z WARN: Attempting to stop gracefully
2013-10-14T18:04:19Z INFO: Shutting down 21 quiet workers
2013-10-14T18:04:49Z WARN: Hard limit of 30sec reached; sending TERM signal
2013-10-14T18:04:49Z INFO: Shutting down 0 quiet workers
2013-10-14T18:04:49Z INFO: Pausing up to 8 seconds to allow workers to finish...
2013-10-14T18:04:57Z INFO: Still waiting for 3 busy workers
2013-10-14T18:04:57Z INFO: Pushed 3 messages back to Redis
2013-10-14T18:04:57Z INFO: All threads stopped; exiting now!
```
