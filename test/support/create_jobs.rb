#!/usr/bin/env ruby

require File.expand_path("../workers", __FILE__)

ForeverWorker.perform_async()

10.times do
  HardWorker.perform_async(Time.now.to_f.to_s)
end
