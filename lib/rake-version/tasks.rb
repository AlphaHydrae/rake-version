
module RakeVersion

  class Tasks < ::Rake::TaskLib

    def initialize &block
      @manager = RakeVersion::Manager.new
      @config = RakeVersion::Config.new
      yield @config if block_given?
      @manager.config = @config
      define
    end

    def define
      desc 'Show the current version'
      task :version do |t|
        puts @manager.version.to_s
      end

      namespace :version do

        desc 'Set the version (e.g. rake version:set[1.2.3])'
        task :set, :value do |t, args|
          puts @manager.set(args.value.to_s)
        end

        namespace :bump do

          [ :major, :minor, :patch ].each do |type|
            desc "Bump the #{type} version"
            task type do |t|
              puts @manager.bump(type).to_s
            end
          end
        end
      end
    end

    def task *args, &block
      super *args do |t, args|
        @manager.with_context context(t) do |m|
          yield t, args if block_given?
        end
      end
    end

    private

    def context task
      RakeVersion::Context.new task
    end
  end
end
