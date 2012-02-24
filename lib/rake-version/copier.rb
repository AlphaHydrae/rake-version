require 'find'

module RakeVersion

  class Copier

    def initialize file_pattern, options = {}
      @file_pattern = file_pattern
      @version_pattern = options[:version_pattern] || /\d+\.\d+\.\d+/
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
        Dir.glob @file_pattern
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
