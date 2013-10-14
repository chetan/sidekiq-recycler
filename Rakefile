# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gemspec|
  gemspec.name        = "sidekiq-recycler"
  gemspec.summary     = "Recycle large sidekiq processes"
  gemspec.description = "Gracefully recycle sidekiq processes that use too much memory"
  gemspec.email       = "chetan@pixelcop.net"
  gemspec.homepage    = "http://github.com/chetan/sidekiq-recycler"
  gemspec.authors     = ["Chetan Sarva"]
  gemspec.license     = "MIT"
end
Jeweler::RubygemsDotOrgTasks.new

Dir['tasks/**/*.rake'].each { |rake| load rake }

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
