
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "logging"
require "micron"

$LOAD_PATH.unshift(File.dirname(__FILE__))

EasyCov.path = "coverage"
EasyCov.filters << EasyCov::IGNORE_GEMS << EasyCov::IGNORE_STDLIB
EasyCov.filters << lambda { |filename|
  filename =~ %r(#{EasyCov.root}/test/)
}
EasyCov.start
