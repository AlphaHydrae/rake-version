
require 'rake/tasklib'

module RakeVersion
  VERSION = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read

  class Error < StandardError; end
  class BadVersionString < Error; end
  class MissingContext < Error; end
  class BadArgument < Error; end
  class BadContext < BadArgument; end
  class BadVersion < BadArgument; end
  class BadBumpType < BadArgument; end

  class Tasks < ::Rake::TaskLib

    def initialize &block
      @manager = RakeVersion::Manager.new
      yield @manager if block_given?
      define
    end

    def task *args, &block
      super *args do |t, args|
        @manager.with_context context(t) do |m|
          yield t, args if block_given?
        end
      end
    end

    def define
      desc 'Show the current version'
      task :version do |t|
        puts @manager.version.to_s
      end

      namespace :version do

        desc 'Set the version (e.g. rake version:set[1.2.3])'
        task :set, :value do |t, args|
          puts @manager.set(args.value.to_s)
        end

        namespace :bump do

          [ :major, :minor, :patch ].each do |type|
            task type do |t|
              puts @manager.bump(type).to_s
            end
          end
        end
      end
    end

    private

    def context task
      RakeVersion::Context.new task
    end
  end

  def self.check_context o
    self.check_type o, RakeVersion::Context, BadContext
  end

  def self.check_version o
    self.check_type o, RakeVersion::Version, BadVersion
  end

  def self.check_type o, expected_type, error_class = Error, name = nil
    name ||= expected_type.to_s.sub(/.*::/, '')
    name = name.downcase
    raise error_class, "Expected #{name} to be a #{expected_type}." unless o.kind_of? expected_type
  end
end

%w( context manager version ).each{ |dep| require File.join(File.dirname(__FILE__), 'rake-version', dep) }
