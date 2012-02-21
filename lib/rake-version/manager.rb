
module RakeVersion

  attr_accessor :namespace
  attr_accessor :root
  attr_accessor :version_filename

  class Manager

    def version context
      RakeVersion::Version.new.from_s(read_version(context))
    end

    private

    def read_version context
      File.open(version_file(context), 'r').read
    end

    def version_file context
      File.join context.root, version_filename
    end

    def version_filename
      @version_filename || 'VERSION'
    end
  end
end
