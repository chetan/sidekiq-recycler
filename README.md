# Sidekiq Recycler
Gracefully recycle sidekiq processes that use too much memory

sidekiq-recycler is a simple middleware which checks the process's RSS usage on
the completion of each job. When the usage surpasses a predefined limit, the process
will gracefully terminate. If any jobs are still running beyond a further time threshold,
they will be killed and requeued.


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
    chain.add Sidekiq::Recycler, :mem_limit => 300_000, :hard_limit_sec => 300
  end
end
```


## Configuration

Two options are exposed by the middleware:

 * mem_limit: RSS usage limit, in megabytes
 * hard_limit_sec: time in seconds to wait for jobs to finish, after graceful shutdown initiated
