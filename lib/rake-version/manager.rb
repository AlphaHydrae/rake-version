
module RakeVersion

  attr_accessor :namespace
  attr_accessor :root
  attr_accessor :version_filename

  class Manager

    def version context
      RakeVersion.check_context context
      RakeVersion::Version.new.from_s(read_version(context))
    end

    def bump type, context
      RakeVersion.check_context context
      save version.bump(type), context
    end

    def save version, context
      RakeVersion.check_version version
      RakeVersion.check_context context
      write_version version.to_s, context
    end

    private

    def read_version context
      context.read version_file(context)
    end

    def write_version version, context
      version.tap{ |v| context.write version_file(context), version.to_s }
    end

    def version_file context
      File.join context.root, version_filename
    end

    def version_filename
      @version_filename || 'VERSION'
    end
  end
end
