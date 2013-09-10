require 'find'

module RakeVersion

  class Copier

    def initialize *args
      options = args.last.kind_of?(Hash) ? args.pop : {}

      @file_patterns = args.collect{ |arg| check_file_pattern arg }
      @version_pattern = Version::REGEXP
      @replace_all = !!options[:all]
    end

    def copy version, context
      find_all_files(context).each{ |f| copy_version f, version }
    end

    private

    def check_file_pattern pattern
      unless [ String, Regexp ].any?{ |klass| pattern.kind_of? klass }
        raise BadFilePattern, "Expected file pattern to be a glob string or regexp, got #{pattern.class.name}."
      end
      pattern
    end

    def copy_version file, version
      File.open(file, 'r+') do |f|
        contents = f.read
        return unless match? contents
        f.rewind
        f.truncate 0
        f.write process(contents, version)
      end
    end

    def match? contents
      contents.match @version_pattern
    end

    def process contents, version
      if @replace_all
        contents.gsub(@version_pattern, version.to_s)
      else
        contents.sub(@version_pattern, version.to_s)
      end
    end

    def find_all_files context
      @file_patterns.collect{ |p| find_files p, context }.flatten
    end

    def find_files pattern, context
      if pattern.kind_of? String
        Dir.chdir context.root
        Dir.glob(pattern).select{ |f| File.file? f }
      elsif pattern.kind_of? Regexp
        files = []
        Find.find(context.root) do |path|
          files << path if File.file?(path) and path.match(pattern)
        end
        files
      end
    end
  end
end
