require 'find'

module RakeVersion

  class Copier

    def initialize *args
      options = HashWithIndifferentAccess.new args.extract_options!

      @file_patterns = args.collect{ |arg| check_file_pattern arg }
      @version_pattern = check_version_pattern(options[:version]) || /\d+\.\d+\.\d+/
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

    def check_version_pattern pattern
      unless pattern.nil? or pattern.kind_of? Regexp
        raise BadVersionPattern, "Expected version option to be a regexp, got #{pattern.class.name}."
      end
      pattern
    end

    def copy_version file, version
      contents = File.open(file, 'r').read
      if @replace_all
        contents.gsub!(@version_pattern, version.to_s)
      else
        contents.sub!(@version_pattern, version.to_s)
      end
      File.open(file, 'w'){ |f| f.write contents }
    end

    def find_all_files context
      @file_patterns.collect{ |p| find_files p, context }.flatten
    end

    def find_files pattern, context
      if pattern.kind_of? String
        Dir.glob(pattern).select{ |f| File.file? f }
      elsif pattern.kind_of? Regexp
        files = []
        Find.find(context.root) do |path|
          files << path if File.file?(path) and path.match(@file_pattern)
        end
        files
      else
        []
      end
    end
  end
end
