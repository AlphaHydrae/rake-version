
module RakeVersion

  class Tasks < ::Rake::TaskLib
    NAMES = [ 'version', 'version:bump:major', 'version:bump:minor', 'version:bump:patch', 'version:set' ]
    OTHER_NAMES = [ 'version:write' ]

    def initialize options = {}, &block
      @manager = RakeVersion::Manager.new
      @config = RakeVersion::Config.new
      yield @config if block_given?
      @manager.config = @config
      define options
    end

    def define options = {}

      clear_tasks options unless options[:clear] == false

      desc 'Show the current version'
      task :version do |t|
        handle_missing_version{ puts @manager.version.to_s }
      end

      namespace :version do

        desc 'Set the version (rake "version:set[1.2.3]")'
        task :set, :value do |t, args|
          puts @manager.set(args.value.to_s)
        end

        namespace :bump do

          [ :major, :minor, :patch ].each do |type|
            desc "Bump the #{type} version"
            task type do |t|
              handle_missing_version{ puts @manager.bump(type).to_s }
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

    def clear_tasks options = {}
      task_names = NAMES
      task_names += OTHER_NAMES unless options[:clear_strict]
      task_names.each{ |task| clear task }
    end

    private

    def handle_missing_version
      return yield if Rake.application.options.trace
      begin
        yield
      rescue MissingVersionFile => e
        warn %|#{e.message}\nCreate it with:\n   rake "version:set[1.0.0]"|
        exit 1
      end
    end

    def clear task
      begin
        Rake::Task[task].clear if Rake::Task[task]
      rescue
        false
      end
    end

    def context task
      RakeVersion::Context.new task.application.original_dir
    end
  end
end
