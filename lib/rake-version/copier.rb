require 'find'

module RakeVersion

  class Copier

    def initialize *args
      options = HashWithIndifferentAccess.new args.extract_options!

      @file_pattern = args.shift
      raise "Expected file pattern to be a string, regexp or array, got #{@file_pattern.class.name}." unless [ String, Regexp, Array ].any?{ |klass| @file_pattern.kind_of? klass }

      @version_pattern = options[:version] || /\d+\.\d+\.\d+/
      raise "Expected version option to be a regexp, got #{options[:version].class.name}." unless @version.nil? or @version.kind_of? Regexp

      @replace_all = options[:all]
    end

    def copy context, version
      find_files(context).each do |file|
        copy_version file, version
      end
    end

    private

    def copy_version file, version
      contents = File.open(file, 'r').read
      if @replace_all
        contents.gsub!(@version_pattern, version.to_s)
      else
        contents.sub!(@version_pattern, version.to_s)
      end
      File.open(file, 'w'){ |f| f.write contents }
    end

    def find_files context
      if @file_pattern.kind_of? String
        Dir.glob(@file_pattern).select{ |f| File.file? f }
      elsif @file_pattern.kind_of? Regexp
        files = []
        Find.find(context.root) do |path|
          files << path if File.file?(path) and path.match(@file_pattern)
        end
        files
      elsif @file_pattern.kind_of? Array
        Dir.chdir context.root
        @file_pattern.collect{ |path| File.expand_path path }
      else
        []
      end
    end
  end
end
