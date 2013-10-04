
require 'rake/tasklib'

module RakeVersion
  VERSION = '0.4.1'

  class Error < StandardError; end
  class BadVersionString < Error; end
  class MissingContext < Error; end
  class MissingVersionFile < Error; end
  class BadArgument < Error; end
  class BadContext < BadArgument; end
  class BadVersion < BadArgument; end
  class BadBumpType < BadArgument; end
  class BadFilePattern < BadArgument; end
  class BadVersionPattern < BadArgument; end

  def self.check_version o
    self.check_type o, RakeVersion::Version, BadVersion
  end

  def self.check_type o, expected_type, error_class = Error, name = nil
    name ||= expected_type.to_s.sub(/.*::/, '')
    name = name.downcase
    raise error_class, "Expected #{name} to be a #{expected_type}." unless o.kind_of? expected_type
  end
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
