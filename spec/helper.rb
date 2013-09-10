require 'rubygems'
require 'bundler'
require 'fakefs/spec_helpers'

require 'simplecov'
SimpleCov.start

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec'
require 'rake-version'
