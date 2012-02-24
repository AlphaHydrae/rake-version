
require 'rake/tasklib'
require 'active_support/core_ext/hash'

module RakeVersion
  VERSION = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read

  class Error < StandardError; end
  class BadVersionString < Error; end
  class MissingContext < Error; end
  class BadArgument < Error; end
  class BadContext < BadArgument; end
  class BadVersion < BadArgument; end
  class BadBumpType < BadArgument; end

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

%w( config context copier manager tasks version ).each{ |dep| require File.join(File.dirname(__FILE__), 'rake-version', dep) }
