
module RakeVersion

  class Version
    REGEXP = /(\d+)\.(\d+)\.(\d+)(?:\-([a-z0-9\-]+(?:\.[a-z0-9\-]+)*))?(?:\+([a-z0-9\-]+(?:\.[a-z0-9\-]+)*))?/i

    attr_reader :major
    attr_reader :minor
    attr_reader :patch
    attr_reader :prerelease
    attr_reader :build

    def initialize
      @major = 0
      @minor = 0
      @patch = 0
      @prerelease = nil
      @build = nil
    end

    def bump type
      case type
      when :major
        @major += 1
        @minor = 0
        @patch = 0
      when :minor
        @minor += 1
        @patch = 0
      when :patch
        @patch += 1
      else
        raise BadBumpType, "Unknown version bump type #{type.inspect}. Expecting :major, :minor or :patch."
      end
      self
    end

    def from_s s
      s.to_s.match(REGEXP).tap do |m|
        raise BadVersionString, "Version '#{s}' expected to have format MAJOR.MINOR.PATCH(-PRERELEASE)(+BUILD)." if m.nil?
        @major = m[1].to_i
        @minor = m[2].to_i
        @patch = m[3].to_i
        @prerelease = m[4]
        @build = m[5]
      end
      self
    end

    def to_s
      String.new.tap do |s|
        s << "#{@major}.#{@minor}.#{@patch}"
        s << "-#{@prerelease}" if @prerelease
        s << "+#{@build}" if @build
      end
    end
  end
end
