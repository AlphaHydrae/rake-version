
require 'rake/tasklib'

module RakeVersion
  VERSION = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read

  class Tasks < ::Rake::TaskLib

    def initialize &block
      @manager = RakeVersion::Manager.new
      yield @manager if block_given?
      define
    end

    def define
      desc 'Show the current version'
      task :version do |t|
        puts @manager.version(context(t)).to_s
      end
    end

    private

    def context task
      RakeVersion::Context.new task
    end
  end
end

%w( context manager version ).each{ |dep| require File.join(File.dirname(__FILE__), 'rake-version', dep) }
