
module RakeVersion

  class Version
    REGEXP = /^(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?((?:\-[A-Za-z0-9]+)*)/

    attr_accessor :major
    attr_accessor :minor
    attr_accessor :patch
    attr_accessor :build
    attr_accessor :tags

    def initialize major = 0, minor = 0, patch = 0, build = nil, tags = []
      @major, @minor, @patch, @build, @tags = major, minor, patch, build, tags
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
        raise Error, "Unknown version bump type #{type.inspect}. Expecting :major, :minor or :patch."
      end
      self
    end

    def from_s s
      s.match(REGEXP).tap do |m|
        raise Error, "Version '#{s}' expected to have format MAJOR.MINOR.PATCH(.BUILD)(-TAG)." if m.nil?
        @major = m[1].to_i
        @minor = m[2].to_i
        @patch = m[3].to_i
        @build = m[4] ? m[4].to_i : nil
        @tags = m[5] ? m[5].sub(/^\-/, '').split('-') : []
      end
      self
    end

    def to_s
      String.new.tap do |s|
        s << "#{@major}.#{@minor}.#{@patch}"
        s << ".#{@build}" if @build
        s << tags.collect{ |tag| "-#{tag}" }.join('') unless tags.empty?
      end
    end
  end
end
